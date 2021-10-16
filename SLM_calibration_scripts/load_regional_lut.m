clear;
close all;

data_dir = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\lut_calibration\photodiode_lut_940_slm5221_combined_64r_10_10_21';

fname = 'slm5221_at940_1064_from_linear_cut.txt';

%% open txt

%% count lines
fileID = fopen([data_dir '\' fname],'r');
num_lines = 0;
while ~feof(fileID)
    temp_data = fgetl(fileID);
    num_lines = num_lines+1;
end
fclose(fileID);

%% get data
data = cell(num_lines,1);
fileID = fopen([data_dir '\' fname],'r');
for n_line = 1:num_lines
    data{n_line,1} = fgetl(fileID);
end
fclose(fileID);

%%
lines_to_check = 30;
start_with_number = false(lines_to_check,1);
for n_line = 1:lines_to_check
    if numel(data{n_line})
        temp_idx = strfind(data{n_line}, 'n_lut_values_horizontal');
        if ~isempty(temp_idx)
            num_lut_val_hor = str2double(data{n_line}((2+numel('n_lut_values_horizontal')):end));
        end
        temp_idx = strfind(data{n_line}, 'n_lut_values_vertical');
        if ~isempty(temp_idx)
            num_lut_val_ver = str2double(data{n_line}((2+numel('n_lut_values_vertical')):end));
        end
        temp_idx = strfind(data{n_line}, 'n_lut_planes');
        if ~isempty(temp_idx)
            num_lut_planes = str2double(data{n_line}((2+numel('n_lut_planes')):end));
        end

        start_with_number(n_line) = and(data{n_line}(1) >=48, data{n_line}(1) <=57);
    end
end
start1 = find(start_with_number,1);

%%
data2 = data(start1:end,:);
num_lines2 = numel(data2);

data_vals = zeros(num_lut_val_ver*num_lut_planes, num_lut_val_hor);
for n_line = 1:num_lines2
    temp_data = data2{n_line};
    temp_data2 = regexp(temp_data, ' ', 'split');
    data_vals(n_line,:) = str2double(temp_data2);
end

%%
n_plane = 100;
figure; imagesc(data_vals(((n_plane-1)*17+(1:17)),:));
