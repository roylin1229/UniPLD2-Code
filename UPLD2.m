%% UPLD2 算法
% 输入：
%   img                 测试图像

% 输出：
%   kps                 图像特征点
%   kp_descs            图像特征点描述符
%   kp_descs_b          图像特征点描述符（二进制）
%   kls                 图像直线段
%   kl_descs            图像直线段描述符
%   kl_descs_b          图像直线段描述符（二进制）

function [kps, kp_descs, kp_descs_b, kls, kl_descs, kl_descs_b] = UPLD2(img)

%% 相关参数设置
param.start_scale           = 4;            % 最小尺度因子
param.scale_level           = 12;           % 最大尺度因子
param.desc_r                = 4;            % 描述符因子

% 特征点检测相关参数
param.fp_desc_u             = true;         % 特征点描述子是否为 Upright
param.point_min_th          = 0.4;          % 特征点响应函数阈值

% 直线段检测相关参数
param.vis_walk              = false;        % 可视化直线段区域生长
param.vis_fit               = false;        % 可视化直线段拟合

param.line_inlier_th        = 22.5;         % 参考 LSD，单位度
param.line_min_len          = 15;           % 最小的线段长度，参考 TPAMI 2024
param.line_min_th           = 4;            % 直线段区域构建阈值，参数消融实验得到的值
param.line_desc_u           = true;         % 直线段描述子是否为 Upright

% 图像相关参数
param.img                   = img;
param.img_r                 = size(img, 1); % 图像尺寸
param.img_c                 = size(img, 2); % 图像尺寸

param.SX                    = repmat(1:size(param.img, 2), size(param.img, 1), 1);
param.SY                    = repmat((1:size(param.img, 1))', 1, size(param.img, 2));

if numel(size(img)) == 3
    img             = rgb2gray(img);
end

%% 主程序
% 提取水平线及水平线差分信息
internal_data       = cell(1, param.scale_level);

for s = param.start_scale:param.scale_level
    % 计算梯度
    [Gx, Gy]            = G_gradient(s, integralImage(double(img)));
    
    % 计算 LLD
    internal_data{s}    = gen_LLD(Gx, Gy, s, param);
end

%% 提取图像特征点
[kps, kp_descs, kp_descs_b]         = UIPD(internal_data, param);

%% 提取图像直线段
[kls, kl_descs, kl_descs_b]         = ULSD(internal_data, param);
kls                                 = kls(:, [1 2 3 4 6]);

end