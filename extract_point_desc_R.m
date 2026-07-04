%% 提取特征点描述符
% 输入：
%   kps                 特征点
%   internal_data       内部中间数据
%   r                   特征点尺度
%   param               相关参数

% 输出：
%   descs_b             特征点描述符（二进制）
%   descs               特征点描述符
%   kps                 特征点

function [descs_b, descs, kps] = extract_point_desc_R(kps, internal_data, s, param)

debug               = false;

% 获取 roi
r                   = param.desc_r * s;
seed_points         = get_rois([0, 0], r, 5);
direction_roi       = seed_points{1};
seeds               = (seed_points{end}(:, 1:2) + seed_points{end}(:, 3:4)) ./ 2;
seeds               = sortrows(seeds);

op_rois             = get_rois([0, 0], 16, 2);
op_rois             = cell2mat(op_rois') + 17;

% 求积分图像
UI                  = internal_data.UI;
VI                  = internal_data.VI;

% 可视化
if debug
    figure
    imshow(param.img)
    % hold on
    % [Y, X]  = find(internal_data.img>-1);
    % hold on
    % quiver(X, Y, internal_data.U(:), internal_data.V(:), 1, 'ShowArrowHead', 'on', 'Color', 'r')
end

% 求描述子
descs               = zeros(size(op_rois, 1)*4, size(kps, 1));
descs_b             = uint8(zeros(size(op_rois, 1)-1, size(kps, 1)));
valid_idx           = false(size(kps, 1), 1);

for i = 1:size(kps, 1)
    tmp_rois        = round([direction_roi(1:2)+kps(i, 1:2), direction_roi(3:4)+kps(i, 1:2)]);
    valid_roi       = sum(tmp_rois(1) > s && tmp_rois(3) <= param.img_c-s && tmp_rois(2) > s && tmp_rois(4) <= param.img_r-s);
    
    if valid_roi
        x2              = tmp_rois(3) + 1;
        y2              = tmp_rois(4) + 1;
        x1              = tmp_rois(1);
        y1              = tmp_rois(2);
        
        UR              = UI(y2, x2) + UI(y1, x1) - UI(y2, x1) - UI(y1, x2);
        VR              = VI(y2, x2) + VI(y1, x1) - VI(y2, x1) - VI(y1, x2);
        
        if debug
            hold on
            rectangle('Position', [tmp_rois(1), tmp_rois(2), tmp_rois(3)-tmp_rois(1), tmp_rois(4)-tmp_rois(2)], 'EdgeColor', 'g');
            % hold on
            % plot(seeds(:, 1)+kps(i, 1), seeds(:, 2)+kps(i, 2), '.c')
            hold on
            quiver(kps(i, 1), kps(i, 2), UR, VR, 0.001, 'ShowArrowHead', 'on', 'Color', 'b')
        end

        theta_radians   = atan(VR/UR);
        R               = [cos(theta_radians), -sin(theta_radians);
                           sin(theta_radians), cos(theta_radians)];
        
        anchors         = (R * seeds(:, 1:2)')';
        anchors         = anchors(:, 1:2)+kps(i, 1:2);
        
        if debug
            % hold on
            % plot(anchors(:, 1), anchors(:, 2), '.m')
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
end

descs               = descs(:, valid_idx)';
descs_b             = descs_b(:, valid_idx)';
kps                 = kps(valid_idx, :);

end
