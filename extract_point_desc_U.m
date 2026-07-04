%% 提取特征点描述符
% 输入：
%   kps                 特征点
%   internal_data       内部中间数据
%   s                   特征点尺度
%   param               相关参数

% 输出：
%   descs_b             特征点描述符（二进制）
%   descs               特征点描述符
%   kps                 特征点

function [descs_b, descs, kps] = extract_point_desc_U(kps, internal_data, s, param)

r                   = param.desc_r * s;
rois                = get_rois([0, 0], r, 2);
rois                = cell2mat(rois');
rois                = round(rois);

UI                  = internal_data.UI;
VI                  = internal_data.VI;
UdI                 = internal_data.UdI;
VdI                 = internal_data.VdI;
SI                  = internal_data.SI;
SdI                 = internal_data.SdI;                

descs               = zeros(size(rois, 1)*2*2, size(kps, 1));
descs_b             = uint8(zeros(size(rois, 1)-1, size(kps, 1)));
valid_idx           = false(size(kps, 1), 1);
for i = 1:size(kps, 1)
    tmp_rois        = round([rois(:, 1:2)+kps(i, 1:2), rois(:, 3:4)+kps(i, 1:2)]);
    valid_flag      = tmp_rois(1, 1) > s && tmp_rois(1, 3) <= param.img_c-s && tmp_rois(1, 2) > s && tmp_rois(1, 4) <= param.img_r-s;
    
    if valid_flag  
        valid_idx(i)    = true;
        
        d1              = tmp_rois(:, 3) + 1;
        d2              = tmp_rois(:, 4) + 1;
        a1              = tmp_rois(:, 1);
        a2              = tmp_rois(:, 2);
        
        SR              = arrayfun(@(x1, y1, x2, y2)  SI(y2, x2)  + SI(y1, x1)  - SI(y2, x1)  - SI(y1, x2),  a1(1), a2(1), d1(1), d2(1));
        SdR             = arrayfun(@(x1, y1, x2, y2) SdI(y2, x2) + SdI(y1, x1) - SdI(y2, x1) - SdI(y1, x2),  a1(1), a2(1), d1(1), d2(1));
        UR              = arrayfun(@(x1, y1, x2, y2)  UI(y2, x2)  + UI(y1, x1)  - UI(y2, x1)  - UI(y1, x2),  a1,    a2,    d1,    d2);
        VR              = arrayfun(@(x1, y1, x2, y2)  VI(y2, x2)  + VI(y1, x1)  - VI(y2, x1)  - VI(y1, x2),  a1,    a2,    d1,    d2);
        UdR             = arrayfun(@(x1, y1, x2, y2) UdI(y2, x2) + UdI(y1, x1) - UdI(y2, x1) - UdI(y1, x2),  a1,    a2,    d1,    d2);
        VdR             = arrayfun(@(x1, y1, x2, y2) VdI(y2, x2) + VdI(y1, x1) - VdI(y2, x1) - VdI(y1, x2),  a1,    a2,    d1,    d2);

        descs(:, i)     = [UR./SR; VR./SR; UdR./SdR; VdR./SdR];
        descs_b(:, i)   = [binary_descriptor(UR), binary_descriptor(VR), binary_descriptor(UdR), binary_descriptor(VdR)];
    end
end

descs               = descs(:, valid_idx)';
descs_b             = descs_b(:, valid_idx)';
kps                 = kps(valid_idx, :);

end
