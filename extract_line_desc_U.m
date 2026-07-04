%% 提取直线段描述符
% 输入：
%   kls                 直线段
%   internal_data       内部中间数据
%   s                   特征点尺度
%   param               相关参数

% 输出：
%   descs_b             直线段描述符（二进制）
%   descs               直线段描述符
%   kls                 直线段

function [descs_b, descs, kls] = extract_line_desc_U(kls, internal_data, s, param)

min_radiu           = param.desc_r * s;

UI                  = internal_data.UI;
VI                  = internal_data.VI;
UdI                 = internal_data.UdI;
VdI                 = internal_data.VdI;
SI                  = internal_data.SI;
SdI                 = internal_data.SdI;                

descs               = zeros(21*2*2, size(kls, 1));
descs_b             = uint8(zeros(20, size(kls, 1)));
valid_idx           = false(size(kls, 1), 1);

% figure
% imshow(param.img)

for i = 1:size(kls, 1)
    point           = (kls(i, 1:2) + kls(i, 3:4)) / 2;
    radiu_w         = max(abs(kls(i, 3) - kls(i, 1)) / 2, min_radiu);
    radiu_h         = max(abs(kls(i, 4) - kls(i, 2)) / 2, min_radiu);
    tmp_rois        = get_rois_rect(point, radiu_w, radiu_h, 2);
    tmp_rois        = round(cell2mat(tmp_rois'));

    % hold on
    % line([kls(i, 1), kls(i, 3)]', [kls(i, 2), kls(i, 4)]', 'Color', 'red')
    % hold on
    % rectangle('Position', [tmp_rois(1), tmp_rois(2), tmp_rois(3)-tmp_rois(1), tmp_rois(4)-tmp_rois(2)], 'EdgeColor', 'g');
    % hold on
    % plot(point(1), point(2), '*b')

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
kls                 = kls(valid_idx, :);

end
