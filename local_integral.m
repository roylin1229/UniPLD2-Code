%% 计算局部积分图像
% 输入：
%   x, y                水平和垂直分量数据
%   p, r                patch 的大小及半径

% 输出：
%   LRD                 局部积分图像响应值
%   LD                  x 和 y 合并后的模长
%   LDI                 LD 的积分图像值                  

function [LRD, LD, LDI] = local_integral(x, y, p, r)

% 求模长
LD                             = sqrt(x.^2 + y.^2);

% 求模长的 Patch 统计值
LDI                            = integralImage(LD);
LRD                            = zeros(size(LD));

LRD(r+1:end-r, r+1:end-r)      = LDI(p+1:end, p+1:end) + LDI(1:end-p, 1:end-p) - ...
                                 LDI(1:end-p, p+1:end) - LDI(p+1:end, 1:end-p);

LRD                            = LRD ./ p^2;

end