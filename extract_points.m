%% 提取特征点
% 输入：
%   scores          特征点响应值
%   s               尺度信息
%   param           相关参数

% 输出：
%   anchors          特征点[x, y, score, scale_size]

function [anchors] = extract_points(scores, s, param, th)

% 计算响应值
[R, C]      = size(scores);

% 选取候选点
points      = efficient_nms(scores, s+1);
points      = points(points(:, 3)>th, :);

% mask
mask        = false(R, C);
idx         = sub2ind([R, C], points(:, 2), points(:, 1));
mask(idx)   = true;

% 排序
points      = sortrows(points, 3, 'descend');

anchors      = zeros(size(points));
select_idx  = false(size(points, 1), 1);

for i = 1:size(points, 1)
    if mask(points(i, 2), points(i, 1))
        rs              = max(1, points(i, 2)-s);
        re              = min(R, points(i, 2)+s);
        cs              = max(1, points(i, 1)-s);
        ce              = min(C, points(i, 1)+s);
                
        tmp_data        = scores(rs:re, cs:ce);
        if max(tmp_data(:))     == points(i, 3)
            select_idx(i)       = true;
            anchors(i, :)       = points(i, :);
            mask(rs:re, cs:ce)  = false;
        end
    end
end

anchors      = anchors(select_idx, :);
anchors      = [anchors (2*param.desc_r*s + 1) *ones(size(anchors, 1), 1)];

end