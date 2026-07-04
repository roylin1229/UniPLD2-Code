%% 计算水平线差分信息，参考 SPL 2023
% 输入：
%   U，V             水平线

% 输出：
%   Udl, Vdl         水平线差分信息
%   O, D             方向及量化方向信息
%   UU, VV           单位水平线
%   S                水平线的长度信息

function [Udl, Vdl, O, D, UU, VV, S] = LLD(U, V)

% 求单位矢量
O                   = atan2(-V, U);
UU                  = cos(O);
VV                  = -sin(O);
S                   = sqrt(U.^2 + V.^2);

img_r               = size(UU, 1);
img_c               = size(UU, 2);

% 提取 level line difference 信息
Ud                  = zeros(img_r-2, img_c-2);
Vd                  = zeros(img_r-2, img_c-2);

% 计算水平线方向（单位，度）
[D]                 = q_Gdir(O*180/pi);

offsets             = [0 1; -1 1; -1 0; -1 -1; 0 -1; 1 -1; 1 0; 1 1];

for i = 1:8
    [i_r, i_c]                      = find(D(2:end-1, 2:end-1)==i);
    Ud(sub2ind(size(Ud), i_r, i_c)) = (UU(sub2ind(size(UU), i_r+1+offsets(i, 1), i_c+1+offsets(i, 2))) - UU(sub2ind(size(UU), i_r+1, i_c+1))) .* ...;
                                    min(S(sub2ind(size(UU), i_r+1+offsets(i, 1), i_c+1+offsets(i, 2))),   S(sub2ind(size(UU), i_r+1, i_c+1)));
    Vd(sub2ind(size(Vd), i_r, i_c)) = (VV(sub2ind(size(VV), i_r+1+offsets(i, 1), i_c+1+offsets(i, 2))) - VV(sub2ind(size(VV), i_r+1, i_c+1))) .* ...;
                                    min(S(sub2ind(size(VV), i_r+1+offsets(i, 1), i_c+1+offsets(i, 2))),   S(sub2ind(size(VV), i_r+1, i_c+1)));
end

Udl                     = zeros(img_r, img_c);
Udl(2:end-1, 2:end-1)   = Ud;
Vdl                     = zeros(img_r, img_c);
Vdl(2:end-1, 2:end-1)   = Vd;

end