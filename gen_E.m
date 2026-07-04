%% 生成直线段候选区域
% 输入：
%   LineRF          线特征的响应值
%   U, V            水平线
%   anchors         锚点
%   param           参数

% 输出：
%   region_map      生成直线段候选区域
%   rep_vecs        候选直线段的代表性数据

function [region_map, rep_vecs] = gen_E(LineR, U, V, Go_pos, anchors, param)

Go_neg                  = zeros(size(Go_pos));
Go_neg(Go_pos > 4)      = Go_pos(Go_pos > 4) - 4;
Go_neg(Go_pos <= 4)     = Go_pos(Go_pos <= 4) + 4;
Go_pos(LineR==0)        = 0;
Go_neg(LineR==0)        = 0;

region_map              = zeros(size(LineR));
region_map(LineR==0)    = -1;

if param.vis_walk
    clf
    set(gcf,'outerposition',get(0,'screensize'));
    imshow(LineR./max(LineR(:)))
    hold on
    [Y, X]  = find(LineR>-1);
    hold on
    quiver(X, Y, U(:), V(:), 1, 'ShowArrowHead', 'on', 'Color', 'g')
    hold on
    plot(anchors(:, 1), anchors(:, 2), '+r')
end

region_idx = 1;
rep_vecs   = {};
for i = 1:size(anchors, 1)
    anchor = anchors(i, :);
    
    if ~region_map(anchor(2), anchor(1))
        rep_vec.vec                         = [0 0];
        rep_vec.num                         = 0;
        rep_vec.sum_vec                     = [0 0];
        rep_vec.region_idx                  = region_idx;
        
        [region_map, rep_vec]               = smart_walk_single(anchor(1), anchor(2), LineR, region_map, rep_vec, U, V, Go_pos, region_idx, param);
        
        region_map(anchor(2), anchor(1))    = 0;
        [region_map, rep_vec]               = smart_walk_single(anchor(1), anchor(2), LineR, region_map, rep_vec, U, V, Go_neg, region_idx, param);
        
        region_map(anchor(2), anchor(1))    = 0;
        [region_map, rep_vec]               = smart_walk(anchor(1), anchor(2), LineR, region_map, rep_vec, U, V, Go_pos, region_idx, param);

        rep_vecs                            = [rep_vecs rep_vec];
        
        region_idx                          = region_idx + 1;
    end
end

end

