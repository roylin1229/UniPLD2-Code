%% 获取特征点描述需要的 ROI 
% 输入：
%   point           中心点
%   radiu           ROI
%   g               空间粒度参数

% 输出：
%   rois            rois

function rois = get_rois(point, radiu, g)

rois            = cell(1, g+1);
init_roi        = [point-radiu point+radiu];
rois{1}         = init_roi;
temp_rois       = init_roi;

for i = 1:g
    next_rois = zeros(size(temp_rois, 1)*4, 4);
    for j = 1:size(temp_rois, 1)
        sub_rois = split_box(temp_rois(j, :));
        next_rois((j-1)*4+1:j*4, :) = sub_rois;
    end
    
    temp_rois   = next_rois;
    rois{i+1}     = temp_rois;
end

end

%%
function [sub_rois] = split_box(roi)

c_m = (roi(1) + roi(3)) / 2;
r_m = (roi(2) + roi(4)) / 2;
sub_rois = [[roi(1) roi(2) c_m r_m]; [roi(1) r_m c_m roi(4)]; [c_m roi(2) roi(3) r_m]; [c_m r_m roi(3) roi(4)]];

end