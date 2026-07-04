%% 提取直线段描述符
% 输入：
%   kls                 直线段
%   internal_data       内部中间数据
%   s                   特征尺度
%   param               相关参数

% 输出：
%   descs_b             直线段描述符（二进制）
%   descs               直线段描述符
%   kls                 直线段

function [descs_b, descs, kls] = extract_line_desc_R(kls, internal_data, s, param)

debug               = false;

% 获取 roi
r                   = param.desc_r * s;

% 可视化
if debug
    figure
    imshow(param.img)
    %     hold on
    %     [Y, X]  = find(internal_data.img>-1);
    %     hold on
    %     quiver(X, Y, internal_data.U(:), internal_data.V(:), 1, 'ShowArrowHead', 'on', 'Color', 'r')
end

% 求描述子
descs               = zeros(84, size(kls, 1));
descs_b             = uint8(zeros(20, size(kls, 1)));
valid_idx           = false(size(kls, 1), 1);
kl_center           = [(kls(:, 3)+kls(:, 1))./2, (kls(:, 4)+kls(:, 2))./2];

op_rois             = get_rois([0, 0], 16, 2);
op_rois             = cell2mat(op_rois') + 17;

for i = 1:size(kls, 1)
    seed_points         = get_rois_rect([0, 0], kls(i, 5)/2, r, 5);
    seeds               = (seed_points{end}(:, 1:2) + seed_points{end}(:, 3:4)) ./ 2;
    seeds               = sortrows(seeds);
    
    theta_radians       = atan((kls(i, 4) - kls(i, 2))/(kls(i, 3) - kls(i, 1)));
    R                   = [cos(theta_radians), -sin(theta_radians);
                           sin(theta_radians), cos(theta_radians)];
    anchors             = (R * seeds(:, 1:2)')';
    anchors             = anchors(:, 1:2)+kl_center(i, 1:2);
    
    if debug
        %         for k = 1:length(seed_points{end})
        %             hold on
        %             rectangle('Position', [seed_points{end}(k, 1), seed_points{end}(k, 2), seed_points{end}(k, 3)-seed_points{end}(k, 1), seed_points{end}(k, 4)-seed_points{end}(k, 2)], 'EdgeColor', 'g');
        %         end
        hold on
        line([kls(i, 1) kls(i, 3)], [kls(i, 2) kls(i, 4)], 'Color', 'r')
        hold on
        plot(anchors(:, 1), anchors(:, 2), '.g')
    end
   
    anchors         = round(anchors);
    
    valid_num       = sum(anchors(:, 1) > s & anchors(:, 1) <= param.img_c-s & anchors(:, 2) > s & anchors(:, 2) <= param.img_r-s);
    
    if valid_num    == size(anchors, 1)
        valid_idx(i) = true;
        
        tmp_U       = zeros(size(anchors, 1), 1);
        tmp_V       = zeros(size(anchors, 1), 1);
        tmp_Ud      = zeros(size(anchors, 1), 1);
        tmp_Vd      = zeros(size(anchors, 1), 1);
        
        for n = 1:size(anchors, 1)
            tmp_U(n)    =  internal_data.U(anchors(n, 2), anchors(n, 1));
            tmp_V(n)    =  internal_data.V(anchors(n, 2), anchors(n, 1));
            tmp_Ud(n)   = internal_data.Ud(anchors(n, 2), anchors(n, 1));
            tmp_Vd(n)   = internal_data.Vd(anchors(n, 2), anchors(n, 1));
        end
        
        if debug
            hold on
            plot(anchors(:, 1), anchors(:, 2), '.m')
            hold on
            quiver(anchors(:, 1), anchors(:, 2), tmp_U, tmp_V, 1, 'ShowArrowHead', 'on', 'Color', 'm')
            hold on
            quiver(anchors(:, 1), anchors(:, 2), tmp_Ud, tmp_Vd, 1, 'ShowArrowHead', 'on', 'Color', 'c')
        end
        
        tmp_data     = (R*[tmp_U tmp_V]')';
        tmp_U        = tmp_data(:, 1);
        tmp_V        = tmp_data(:, 2);
        tmp_data     = (R*[tmp_Ud tmp_Vd]')';
        tmp_Ud       = tmp_data(:, 1);
        tmp_Vd       = tmp_data(:, 2);
        
        if debug
            hold on
            quiver(anchors(:, 1), anchors(:, 2), tmp_U, tmp_V, 1, 'ShowArrowHead', 'on', 'Color', 'y')
            hold on
            quiver(anchors(:, 1), anchors(:, 2), tmp_Ud, tmp_Vd, 1, 'ShowArrowHead', 'on', 'Color', 'g')
        end
        
        tmp_U        = reshape(tmp_U, sqrt(length(tmp_U)), sqrt(length(tmp_U)));
        tmp_V        = reshape(tmp_V, sqrt(length(tmp_V)), sqrt(length(tmp_V)));
        tmp_Ud       = reshape(tmp_Ud, sqrt(length(tmp_Ud)), sqrt(length(tmp_Ud)));
        tmp_Vd       = reshape(tmp_Vd, sqrt(length(tmp_Vd)), sqrt(length(tmp_Vd)));
        
        SR           = sum(sum(sqrt(tmp_U.^2 + tmp_V.^2)));
        SdR          = sum(sum(sqrt(tmp_Ud.^2 + tmp_Vd.^2)));
        
        tmp_UI       = integralImage(tmp_U);
        tmp_VI       = integralImage(tmp_V);
        tmp_UdI      = integralImage(tmp_Ud);
        tmp_VdI      = integralImage(tmp_Vd);
        
        d1              = op_rois(:, 3);
        d2              = op_rois(:, 4);
        a1              = op_rois(:, 1);
        a2              = op_rois(:, 2);
        
        tmp_UR          = arrayfun(@(x1, y1, x2, y2) tmp_UI(y2, x2) + tmp_UI(y1, x1) - tmp_UI(y2, x1) - tmp_UI(y1, x2), a1, a2, d1, d2);
        tmp_VR          = arrayfun(@(x1, y1, x2, y2) tmp_VI(y2, x2) + tmp_VI(y1, x1) - tmp_VI(y2, x1) - tmp_VI(y1, x2), a1, a2, d1, d2);
        tmp_UdR         = arrayfun(@(x1, y1, x2, y2) tmp_UdI(y2, x2) + tmp_UdI(y1, x1) - tmp_UdI(y2, x1) - tmp_UdI(y1, x2), a1, a2, d1, d2);
        tmp_VdR         = arrayfun(@(x1, y1, x2, y2) tmp_VdI(y2, x2) + tmp_VdI(y1, x1) - tmp_VdI(y2, x1) - tmp_VdI(y1, x2), a1, a2, d1, d2);
        
        descs(:, i)     = [tmp_UR./SR; tmp_VR./SR; tmp_UdR./SdR; tmp_VdR./SdR];
        descs_b(:, i)   = [binary_descriptor(tmp_UR), binary_descriptor(tmp_VR), binary_descriptor(tmp_UdR), binary_descriptor(tmp_VdR)];
    end
end

descs               = descs(:, valid_idx)';
descs_b             = descs_b(:, valid_idx)';
kls                 = kls(valid_idx, :);

end
