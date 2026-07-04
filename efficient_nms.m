%% Efficient NMS 算法
% 输入：
%   image               输入图像
%   p                   块尺寸

% 输出：
%   max_indices         最大值索引

function max_indices = efficient_nms(score_map, p)

% Get the size of the input image
[R, C]      = size(score_map);

% Initialize arrays to store maximum values and their indices
num_blocks  = ceil(C/p) * ceil(R/p);
max_indices = zeros(num_blocks, 3);
idx         = 1;

% Loop through each p*p block
for i = 1:p:R
    for j = 1:p:C
        % Define the block boundaries
        block_i_end     = min(i + p - 1, R);
        block_j_end     = min(j + p - 1, C);
        
        % Extract the block
        block           = score_map(i:block_i_end, j:block_j_end);
        
        % Find the maximum value and its linear index within the block
        [block_max_value, block_max_idx] = max(block(:));
        [block_max_row, block_max_col]   = ind2sub(size(block), block_max_idx);
 
        % Compute the actual row and column indices in the original image
        max_row         = i + block_max_row - 1;
        max_col         = j + block_max_col - 1;
        
        % Store the maximum value and its original image index
        max_indices(idx, :) = [max_col, max_row, block_max_value];
        
        idx                 = idx + 1;
    end
end

end
