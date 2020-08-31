function [file_names, data] = f_SLM_get_file_names(dir_path, tag, load_data)


lut_list = dir([dir_path, '\' tag]);
num_luts = numel(lut_list);
file_names = cell(num_luts,1);
for n_lut = 1:num_luts
    file_names{n_lut} = lut_list(n_lut).name;
end

if load_data
    data = cell(num_luts,1);
    for n_lut = 1:num_luts
        data{n_lut} = load([dir_path '\' file_names{n_lut}]);
    end 
end

end