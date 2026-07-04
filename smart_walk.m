%% 区域生长法
% 输入：
%   x, y            当前点
%   R               响应值矩阵
%   map             区域 map
%   UIRF, VIRF      patched level lines
%   Ds              方向信息
%   region_idx      区域索引
%   param           相关参数

% 输出：
%   map             区域 map

function [map, rep_vec] = smart_walk(x, y, R, map, rep_vec, UIR, VIR, Ds, region_idx, param)

D               = Ds(y, x);

if D == 0
    return;
end

% 获取候选搜索值
os              = [0 1; -1 1; -1 0; -1 -1; 0 -1; 1 -1; 1 0; 1 1];

[row, col]      = size(R);

candidates      = [x y R(y, x)];

while ~isempty(candidates)
    
    [~, can_idx]        = max(candidates(:, end));
    x                   = candidates(can_idx, 1);
    y                   = candidates(can_idx, 2);
    
    candidates(can_idx, :) = [];
    
    if x<col && x>1 && y<row && y>1 && R(y, x)>0 && ~map(y, x)
        
        map(y, x)           = region_idx;
        rep_vec.sum_vec     = rep_vec.sum_vec + [UIR(y,   x)    VIR(y,   x)];
        rep_vec.num         = rep_vec.num + 1;
        rep_vec.vec         = rep_vec.sum_vec ./ rep_vec.num;
        
        next_pts            = [x, y] + os(:, [2, 1]);
        
        if param.vis_walk
            hold on
            quiver(x, y, rep_vec.vec(1), rep_vec.vec(2), 0.005, 'ShowArrowHead', 'on', 'Color', 'r')
            hold on
            plot(next_pts(:, 1), next_pts(:, 2), 'om')
            pause(0.00001)
        end
        
        next_u              = arrayfun(@(y, x) UIR(y, x), next_pts(:, 2), next_pts(:, 1));
        next_v              = arrayfun(@(y, x) VIR(y, x), next_pts(:, 2), next_pts(:, 1));
        next_map            = arrayfun(@(y, x) map(y, x), next_pts(:, 2), next_pts(:, 1));
        next_s              = arrayfun(@(y, x) R(y, x),   next_pts(:, 2), next_pts(:, 1));
        
        n_vec               = [next_u next_v];
        c_vec               = ones(size(n_vec, 1), 1) * rep_vec.vec;
        angle               = acosd(dot(n_vec, c_vec, 2) ./ (vecnorm(n_vec, 2, 2) .* vecnorm(c_vec, 2, 2)));
        inliers             = angle < param.line_inlier_th & ~next_map;
        
        candidates          = [candidates; [next_pts(inliers, :) next_s(inliers)]];
    end
end

end