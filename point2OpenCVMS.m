%% 转换点特征为opencv格式
% 输入：
%   points                  特征点位置
%   scores                  特征点分数

% 输出：
%   keypoints               opencv 格式的点特征  

function [keypoints] = point2OpenCVMS(points, scores, sizes)

% 预分配结构体数组
num_points = size(points, 1);
keypoints(num_points) = struct('pt', [], 'response', [], 'size', [], 'angle', [], 'octave', [], 'class_id', []);

% 填充结构体数组
for i = 1:num_points
    keypoints(i).pt = points(i,:) - 1;
    keypoints(i).response = scores(i);
    keypoints(i).size = sizes(i);
    keypoints(i).angle = -1;
    keypoints(i).octave = 0;
    keypoints(i).class_id = 0;
end

end