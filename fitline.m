%% 从区域图中，拟合直线段
% 输入：
%   LineRF          线特征的响应值
%   UIRF, VIRF      水平线
%   param           相关参数
%   region_map      生成直线段候选区域
%   rep_vecs        候选直线段的代表性数据

% 输出：
%   lines           直线段

function [lines] = fitline(region_map, rep_vecs, LineR, U, V, param)

if param.vis_fit
    clf
    set(gcf,'outerposition',get(0,'screensize'));
    imshow(LineR./max(LineR(:)))
end

max_lines = length(rep_vecs);
lines     = zeros(max_lines, 6);

for i = 1:max_lines
    idx             = find(region_map == rep_vecs{i}.region_idx);
    
    % 剔除外点
    u               = U(idx);
    v               = V(idx);

    n_vec           = [u v];
    c_vec           = ones(size(n_vec, 1), 1) * rep_vecs{i}.vec;
    angle           = acosd(dot(n_vec, c_vec, 2) ./ (vecnorm(n_vec, 2, 2) .* vecnorm(c_vec, 2, 2)));

    inliers         = angle < param.line_inlier_th;
    idx             = idx(inliers);
        
    % 计算代表性的点
    s               = LineR(idx);
        
    [r, c]          = ind2sub(size(region_map), idx);
    
    center          = [sum(s.*c), sum(s.*r)] ./ sum(s);    % 列，行
    tangent_vec     = [sum(u(inliers)), sum(v(inliers))] ./ sum(inliers);
    
    [ps, pe, len, ~, vtx]   = cal_project_point([c, r]-center, tangent_vec);
    lines(i, :)             = [ps+center pe+center len sum(s)];
    
    if param.vis_fit
        hold on
        quiver(c, r, u(inliers), v(inliers), 0.3, 'ShowArrowHead', 'on', 'Color', 'r')
        hold on
        plot(ps(:, 1)+center(1), ps(:, 2)+center(2), '+r')
        hold on
        plot(pe(:, 1)+center(1), pe(:, 2)+center(2), '+c')
        hold on
        plot(center(1), center(2), '+g')
        hold on
        plot(vtx(:, 1)+center(1), vtx(:, 2)+center(2), '-g')
        hold on
        quiver(center(1), center(2), tangent_vec(1), tangent_vec(2), 0.5, 'ShowArrowHead', 'on', 'Color', 'm', 'LineWidth', 3)
        axis([min(vtx(:, 1)+center(1)) max(vtx(:, 1)+center(1)) min(vtx(:, 2)+center(2)) max(vtx(:, 2)+center(2))])
    end
end

lines = lines(lines(:, 5)>=param.line_min_len, :);

end

%% 计算点在向量上的垂足
% point: 要计算的点，格式为 [x, y]
% vector: 向量，格式为 [vx, vy]

function [ps, pe, linelength, ratio, vtx] = cal_project_point(point, vector)

% 计算向量的模长
vectorMagnitude     = sqrt(vector(1)^2 + vector(2)^2);

% 计算向量的单位向量
unitVector          = vector / vectorMagnitude;
unitVector          = ones(size(point, 1), 1) * unitVector;

% 计算点到向量的投影长度
projectionLength    = dot(point, unitVector, 2);

% 计算投影向量
project_point       = projectionLength .* unitVector;

% 计算起始点
[minlen, idxs]      = min(projectionLength);
[maxlen, idxe]      = max(projectionLength);
ps                  = project_point(idxs, :);
pe                  = project_point(idxe, :);
linelength          = maxlen - minlen;

% 计算垂直差异向量
lat_vec             = point - project_point;
lat_vec_dis         = unitVector(:, 1).*lat_vec(:, 2) - unitVector(:, 2).*lat_vec(:, 1);

[minlat, ~]         = min(lat_vec_dis);
[maxlat, ~]         = max(lat_vec_dis);

ratio               = size(point, 1) ./ (linelength*(maxlat-minlat));

% 计算外接矩形
vtx                 = [lat_vec(idxs, :) ./ lat_vec_dis(idxs) .* minlat + ps; ...
                       lat_vec(idxs, :) ./ lat_vec_dis(idxs) .* maxlat + ps; 
                       lat_vec(idxe, :) ./ lat_vec_dis(idxe) .* maxlat + pe;
                       lat_vec(idxe, :) ./ lat_vec_dis(idxe) .* minlat + pe; ];
vtx                 = [vtx(end, :); vtx];

if 0
    clf
    set(gcf,'outerposition',get(0,'screensize'));
    axis equal
    hold on
    quiver(ps(1), ps(2), vector(1), vector(2), 0.2, 'ShowArrowHead', 'on', 'Color', 'g')
    hold on
    plot(point(:, 1), point(:, 2), '.r')
    [~, max_idx] = max(lat_vec_dis);
    hold on
    quiver(project_point(max_idx, 1), project_point(max_idx, 2), lat_vec(max_idx, 1), lat_vec(max_idx, 2), 1, 'ShowArrowHead', 'on', 'Color', 'g')
    [~, min_idx] = min(lat_vec_dis);
    hold on
    quiver(project_point(min_idx, 1), project_point(min_idx, 2), lat_vec(min_idx, 1), lat_vec(min_idx, 2), 1, 'ShowArrowHead', 'on', 'Color', 'g')
    hold on
    plot(vtx(:, 1), vtx(:, 2), '-b')
end

end