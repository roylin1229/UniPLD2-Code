%% 提取图像直线段及描述符
% 输入：
%   internal_data               内部数据
%   param                       相关参数

% 输出：
%   kls                         直线段
%   kl_descs                    直线段描述符
%   kl_descs_b                  直线段描述符（二进制）

function [kls, kl_descs, kl_descs_b] = ULSD(internal_data, param)

kls             = cell(1, param.scale_level);
kl_descs        = cell(1, param.scale_level);
kl_descs_b      = cell(1, param.scale_level);

for s = param.start_scale
    % 计算直线段
    [kls{s}]                     = extract_line(internal_data{s}, s, param);
    
    % 计算描述子
    if param.line_desc_u
        [kl_descs_b{s}, kl_descs{s}, kls{s}]        = extract_line_desc_U(kls{s}, internal_data{s}, s, param);
    else
        [kl_descs_b{s}, kl_descs{s}, kls{s}]        = extract_line_desc_R(kls{s}, internal_data{s}, s, param);
    end
end

%% 特征点后处理：排序并转换格式
kls             = cell2mat(kls(param.start_scale)');
kl_descs        = single(cell2mat(kl_descs(param.start_scale)'));
kl_descs_b      = cell2mat(kl_descs_b(param.start_scale)');

end