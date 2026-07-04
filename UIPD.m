%% 提取图像特征点及描述符
% 输入：
%   internal_data               内部数据
%   param                       相关参数

% 输出：
%   kps                         特征点
%   kp_descs                    特征点描述符
%   kp_descs_b                  特征点描述符（二进制）

function [kps, kp_descs, kp_descs_b] = UIPD(internal_data, param)

kps             = cell(1, param.scale_level);
kp_descs        = cell(1, param.scale_level);
kp_descs_b      = cell(1, param.scale_level);

for s = param.start_scale:param.scale_level
    p                              = 2*s + 1;
    
    % 求模长的 Patch 统计值
    LRD                            = zeros(size(internal_data{s}.Sd));
    LRD(s+1:end-s, s+1:end-s)      = internal_data{s}.SdI(p+1:end, p+1:end) + internal_data{s}.SdI(1:end-p, 1:end-p) - ...
                                     internal_data{s}.SdI(1:end-p, p+1:end) - internal_data{s}.SdI(p+1:end, 1:end-p);
    LRD                            = LRD ./ p^2;
    
    % 计算特征点
    [anchors]                      = extract_points(LRD, s, param, param.point_min_th);

    % 计算特征点的图心
    SX                             = param.SX.*internal_data{s}.Sd;
    SY                             = param.SY.*internal_data{s}.Sd;

    SXI                            = integralImage(SX);
    SXD                            = zeros(size(internal_data{s}.Sd));
    SXD(s+1:end-s, s+1:end-s)      = SXI(p+1:end, p+1:end) + SXI(1:end-p, 1:end-p) - SXI(1:end-p, p+1:end) - SXI(p+1:end, 1:end-p);

    SYI                            = integralImage(SY);
    SYD                            = zeros(size(internal_data{s}.Sd));
    SYD(s+1:end-s, s+1:end-s)      = SYI(p+1:end, p+1:end) + SYI(1:end-p, 1:end-p) - SYI(1:end-p, p+1:end) - SYI(p+1:end, 1:end-p);

    kps_idx                        = sub2ind([param.img_r, param.img_c], anchors(:, 2), anchors(:, 1));
    kps{s}                         = anchors;
    kps{s}(:, 1:2)                 = [SXD(kps_idx), SYD(kps_idx)] ./ (LRD(kps_idx)*p^2);

    if 0
        figure
        subplot(121)
        imshow(param.img)
        subplot(122)
        imshow(LRD./max(LRD(:)))
        hold on
        plot(anchors(:, 1), anchors(:, 2), '+r')
        hold on
        plot(kps{s}(:, 1), kps{s}(:, 2), 'og')
    end

    % 计算描述子
    if param.fp_desc_u
        [kp_descs_b{s}, kp_descs{s}, kps{s}]      = extract_point_desc_U(kps{s}, internal_data{s}, s, param);
    else
        [kp_descs_b{s}, kp_descs{s}, kps{s}]      = extract_point_desc_R(kps{s}, internal_data{s}, s, param);
    end
end

%% 特征点后处理：排序并转换格式
kps             = cell2mat(kps(param.start_scale:param.scale_level)');
kp_descs        = cell2mat(kp_descs(param.start_scale:param.scale_level)');
kp_descs_b      = cell2mat(kp_descs_b(param.start_scale:param.scale_level)');
[kps, idx]      = sortrows(kps, 3, 'descend');

max_num         = min(2000, size(kps, 1));
kp_descs        = single(kp_descs(idx(1:max_num), :));
kp_descs_b      = kp_descs_b(idx(1:max_num), :);
kps             = kps(1:max_num, :);

% if ~isempty(kps)
%     max_num     = min(5000, size(kps, 1));
%     max_num     = size(kps, 1);
%     [kps]       = point2OpenCVMS(kps(1:max_num, 1:2), kps(1:max_num, 3), kps(1:max_num, 4));
%     kp_descs    = kp_descs(1:max_num, :);
%     kp_descs_b  = kp_descs_b(1:max_num, :);
% end

end