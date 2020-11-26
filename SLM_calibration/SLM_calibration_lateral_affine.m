clear

files_dir = 'C:\Users\ys2605\Desktop\stuff\SLM_outputs\XYZcalibration\XYZcalibration\3_3_20\lateral_calibration_images';

% for 20X zoom 1 256 pixel/um ratio

file_list = dir([files_dir, '\' '*.tif']);
num_files = numel(file_list);
file_names = cell(num_files,1);
for n_file = 1:num_files
    file_names{n_file} = file_list(n_file).name;
end

input_coords = zeros(num_files,2);      % (x,y)  coordinates for each file
for n_file = 1:num_files
    dist = regexp(file_names{n_file},'\d*','Match');
    dist = str2double(dist{1});
    if contains(file_names{n_file}, '-')
        dist = -dist;
    end
    
    if contains(lower(file_names{n_file}),'x')
        input_coords(n_file,1) = dist;
    elseif contains(lower(file_names{n_file}),'y')
        input_coords(n_file,2) = dist;
    end
end

temp_Y = imread([files_dir '\' file_names{1}], 'tif');
[dim1, dim2] = size(temp_Y);

Y = zeros(dim1,dim2,num_files, 'uint16');
Y(:,:,1) = temp_Y;

for n_file = 2:num_files
    Y(:,:,n_file) = imread([files_dir '\' file_names{n_file}], 'tif');
end

zero_ord_coords = zeros(num_files,2);
first_ord_coords = zeros(num_files,2);
figure;
for n_file = 1:num_files
    imagesc(Y(:,:,n_file)); axis tight equal;
    title([file_names{n_file} ' Click on zero order spot']);
    [x1, y1] = ginput(1);
    zero_ord_coords(n_file,:) = round([x1, y1]);
    title([file_names{n_file} ' Click on first order spot']);
    [x1, y1] = ginput(1);
    first_ord_coords(n_file,:) = round([x1, y1]);
end
close;

displacement_mat = first_ord_coords-zero_ord_coords;

% transform_mat*input_coords = displacement_mat
lateral_affine_transform_mat = inv(input_coords\displacement_mat);

save([files_dir '\' 'lateral_affine_transform_mat_3_3_20.mat'], 'lateral_affine_transform_mat')
