%% 量化梯度方向并指派方向
% 输入：
%   Ldir            角度

% 输出：
%   directions      方向

function [directions] = q_Gdir(Ldir)

directions  = zeros(size(Ldir));

idx_list = [-22.5   22.5; 
             22.5   67.5; 
             67.5   112.5; 
             112.5  157.5; 
            -157.5 -112.5; 
            -112.5 -67.5; 
            -67.5  -22.5];
ids      = [1           2          3           4            6            7            8];

for i = 1:size(idx_list, 1)
    sel_idx     = Ldir > idx_list(i, 1) & Ldir <= idx_list(i, 2);
    directions(sel_idx) = ids(i);
end

down_range      = [157.5 180; -180 -157.5];
down_idx        = (Ldir > down_range(1, 1) & Ldir <= down_range(1, 2)) | (Ldir >= down_range(2, 1) & Ldir <= down_range(2, 2));
directions(down_idx)    = 5;

end
