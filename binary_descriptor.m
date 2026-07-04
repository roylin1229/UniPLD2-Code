function [final_desc]   = binary_descriptor(data_input)

temp_values_intra              = reshape(data_input(2:end),  4, length(data_input(2:end))/4);
mean_values_intra              = mean(temp_values_intra);
descs_intra                    = temp_values_intra > mean_values_intra;
descs_intra                    = uint8(descs_intra);
final_desc                     = 8.*descs_intra(1, :) + 4.*descs_intra(2, :) + 2.*descs_intra(3, :) + descs_intra(4, :);

end