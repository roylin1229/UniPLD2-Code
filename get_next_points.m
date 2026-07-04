%% 根据当前点的level lines，得到跟踪点
% 输入：
%   Ds              方向map
%   x,y             当前点位置
%   offsets         偏移量

% 输出：
%   os              跟踪点

function [os] = get_next_points(Ds, x, y, offsets)

D               = Ds(y, x);

if D == -1
    os = [];
    return;
end

if D == 1
    os          = [offsets(1, :); offsets(2, :); offsets(8, :)];
elseif D == 8
    os          = [offsets(8, :); offsets(1, :); offsets(7, :)];
else
    os          = [offsets(D, :); offsets(D+1, :); offsets(D-1, :)];
end

end