%% 提取直线段特征
% 输入：
%   LineRF          线特征的响应值
%   UIRF, VIRF      patched level lines
%   param           相关参数
%   img             测试图像

% 输出：
%   linesF          直线段特征

function [linesF] = extract_line(internal_data, s, param)

% 提取局部极大值，表示最有可能是直线段的点，表达方式 x y
LineR                               = internal_data.S-internal_data.Sd;
LineR(LineR < param.line_min_th)    = 0;

anchors                             = extract_points(LineR, s, param, param.line_min_th);
anchors                             = anchors(anchors(:, 3)>param.line_min_th, :);

% 生成候选区域
[region_map, rep_vecs]              = gen_E(LineR, internal_data.U, internal_data.V, internal_data.D, anchors(:, 1:2), param);

% 直线段拟合
linesF                              = fitline(region_map, rep_vecs, internal_data.S, internal_data.U, internal_data.V, param);
linesF                              = sortrows(linesF, 6, 'descend');
linesF                              = [linesF ones(size(linesF, 1), 1)*s];

% 根据 anchors 提取直线段
if 0
    clf
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(121)
    imshow(LineR./max(LineR(:)))
    k = 10;
    hold on
    line([linesF(:, 1) linesF(:, 3)]', [linesF(:, 2) linesF(:, 4)]', 'Color', 'c')
    hold on
    line([linesF(1:k, 1) linesF(1:k, 3)]', [linesF(1:k, 2) linesF(1:k, 4)]', 'Color', 'r')
    
    subplot(122)
    imshow(param.img)
    hold on
    line([linesF(:, 1) linesF(:, 3)]', [linesF(:, 2) linesF(:, 4)]', 'Color', 'c')
end

end