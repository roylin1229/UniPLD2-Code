%% 生成水平线及差分等相关信息
% 输入：
%   Gx, Gy          图像梯度
%   r               运算区域范围
%   param           相关参数

% 输出：
%   internal_data   内部数据
    
function [internal_data] = gen_LLD(Gx, Gy, r, param)

r                   = param.desc_r * r;
p                   = 2*r + 1;

% 计算局部梯度相对幅度
[GfR, Gf, GfI]      = local_integral(Gx, Gy, p, r);
RS                  = Gf ./ GfR;
RS(GfR == 0)        = 1;

% 计算全局梯度相对幅度（去中心化）
Gx                  = Gx ./ (GfI(end, end)/(param.img_r*param.img_c));
Gy                  = Gy ./ (GfI(end, end)/(param.img_r*param.img_c));

% 可视化
if 0
    clf
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(221)
    imshow(Gf./max(Gf(:)))
    subplot(222)
    imshow(GfR./max(GfR(:)))
    subplot(223)
    imshow(RS./max(RS(:)))
    subplot(224)
    imshow((RS.*Gf)./max((RS(:).*Gf(:))))
end

% 提取 level line 信息
G_vec               = [0, 1; -1, 0] * [Gx(:).*RS(:) Gy(:).*RS(:)]';
U                   = reshape(G_vec(1, :), [param.img_r, param.img_c]);
V                   = reshape(G_vec(2, :), [param.img_r, param.img_c]);

% 计算 LLD 信息
[Ud, Vd, O, D, UU, VV, S] = LLD(U, V);

% 保存相关数据
% 水平线
internal_data.U         = U;
internal_data.V         = V;
internal_data.UI        = integralImage(U);
internal_data.VI        = integralImage(V);
internal_data.S         = S;
internal_data.SI        = integralImage(S);

% 水平线差分
internal_data.Ud        = Ud;
internal_data.Vd        = Vd;
internal_data.UdI       = integralImage(Ud);
internal_data.VdI       = integralImage(Vd);
internal_data.Sd        = sqrt(Ud.^2 + Vd.^2);
internal_data.SdI       = integralImage(internal_data.Sd);

% 单位水平线
internal_data.UU        = UU;
internal_data.VV        = VV;

% 水平线方向
internal_data.O         = O;
internal_data.D         = D;

% 可视化
if 0
    clf
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(121)
    imshow(param.img)
    hold on
    [Y, X]  = find(param.img>-1);
    %     hold on
    %     quiver(X, Y, Gx(:), Gy(:), 1, 'ShowArrowHead', 'on', 'Color', 'r')
    hold on
    quiver(X, Y, U(:), V(:), 1, 'ShowArrowHead', 'on', 'Color', 'g')
    hold on
    quiver(X, Y, Ud(:), Vd(:), 1, 'ShowArrowHead', 'on', 'Color', 'm')
    subplot(122)
    imshow(S./max(S(:)))
end

end
