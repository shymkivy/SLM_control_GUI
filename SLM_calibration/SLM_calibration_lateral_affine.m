%% XY affine calibration
% collect all images in same folder and name each with disp value "X_20" or "Y_-50"
clear

%%
% 20x full 637.4um
full_fov_size = 637.4;
zoom = 6;
fov_pix_x = 256;
foc_pix_y = 256;
beads = 1;

xy_pix_step = [full_fov_size/zoom/fov_pix_x, full_fov_size/zoom/foc_pix_y];

save_name = 'lateral_calib_maitai_z6_12_21_20';

%%
files_dir = 'E:\data\SLM\XYZcalibration\XYZcalibration\12_21_20\6z\combined';

% for 20X zoom 1 256 pixel/um ratio
%%
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
if beads
    input_coords = -input_coords;
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
% displacement_mat2 = displacement_mat*diag(xy_pix_step);
% 
% figure; plot(input_coords(:,1), displacement_mat2(:,1),  '-o');
% xlabel('x input'); ylabel('x displacement');
% 
% figure; plot(input_coords(:,2), displacement_mat2(:,2),  '-o')
% xlabel('y input'); ylabel('y displacement');
% 
% % transform_mat*input_coords = displacement_mat
% 
% lateral_affine_transform_mat = inv(input_coords\displacement_mat);

% aff1 = input_coords\displacement_mat;
% aff1_inv = inv(input_coords\displacement_mat);
% input_coords*aff1*aff1_inv
% displacement_mat*aff1_inv
% input_coords*aff1

%lateral_affine_transform_mat3 = diag(xy_calib)\lateral_affine_transform_mat;
%lateral_affine_transform_mat2 = inv(input_coords\displacement_mat2);

%save([files_dir '\' save_name '.mat'], 'lateral_affine_transform_mat', 'xy_pix_step')
save([files_dir '\' save_name '.mat'], 'displacement_mat', 'input_coords', 'xy_pix_step');