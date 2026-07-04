%% 通过积分图像计算近似的高斯微分梯度（参考：Robust Low Complexity Corner Detector (TCSVT 2011)）
% 输入：
%   r           运算区域范围
%   imgI        积分图像

% 输出：
%   Gxl, Gyl    水平及垂直梯度

function [Gxl, Gyl] = G_gradient(r, imgI)

p       = 2*r + 1;                                  % 运算区域大小

pxn     = [1,   2, r, p-2];                       % x y w h
pxp     = [r+2, 2, r, p-2];

Gxn     = int_unit_Gx(imgI, pxn, r + 1);
Gxp     = int_unit_Gx(imgI, pxp, 0);

pyn     = pxn([2 1 4 3]);                           % x y w h
pyp     = pxp([2 1 4 3]);
Gyn     = int_unit_Gy(imgI, pyn, r + 1);
Gyp     = int_unit_Gy(imgI, pyp, 0);

Gx      = Gxp - Gxn;
Gy      = Gyp - Gyn;

Gxl     = zeros(size(imgI)-1);
Gyl     = zeros(size(imgI)-1);

Gxl(r+1:end-r, r+1:end-r) = Gx;
Gyl(r+1:end-r, r+1:end-r) = Gy;

end

%%
function [R] = int_unit_Gx(imgI, b, o)

x = b(1); 
y = b(2); 
w = b(3); 
h = b(4); 

r = size(imgI, 1);
c = size(imgI, 2);

R1 = imgI(y:r-h-1, x:c-o-w); 
R2 = imgI(y+h:r-1, x:c-o-w); 
R3 = imgI(y:r-h-1, x+w:c-o); 
R4 = imgI(y+h:r-1, x+w:c-o); 

R  = R4 + R1 - R2 - R3;

end

%%
function [R] = int_unit_Gy(imgI, b, o)

x = b(1); 
y = b(2); 
w = b(3); 
h = b(4); 

r = size(imgI, 1);
c = size(imgI, 2);

R1 = imgI(y:r-h-o, x:c-w-1); 
R2 = imgI(y+h:r-o, x:c-w-1); 
R3 = imgI(y:r-h-o, x+w:c-1); 
R4 = imgI(y+h:r-o, x+w:c-1); 

R  = R4 + R1 - R2 - R3;

end