function f_sg_pp_load_images(app)

path1 = app.imagedirEditField.Value;

files1 = dir(path1);
files1(strcmpi({files1.name}, '.'),:) = [];
files1(strcmpi({files1.name}, '..'),:) = [];
files1([files1.isdir],:) = [];

num_files = numel(files1);

im_all = cell(num_files,1);
xyz_all = zeros(num_files,3);
for n_file = 1:numel(files1)
    im1 = imread([path1 '\' files1(n_file).name]);
    im_all{n_file} = im1;
    
    temp_str = lower(files1(n_file).name);
        
    xyz_all(n_file,1) = f_sg_lc_get_coord_from_string(temp_str, 'x');
    xyz_all(n_file,2) = f_sg_lc_get_coord_from_string(temp_str, 'y');
    xyz_all(n_file,3) = f_sg_lc_get_coord_from_string(temp_str, 'z');
    
end

app.app_main.pattern_editor_data.im_all = im_all;
app.app_main.pattern_editor_data.xyz_all = xyz_all;

f_sg_pp_update_bkg_im(app);

fprintf('Loaded %d pattern editor images\n', numel(xyz_all));
end