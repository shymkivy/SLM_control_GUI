function f_sg_pp_load_images(app)

path1 = app.imagedirEditField.Value;

files1 = dir(path1);
files1(strcmpi({files1.name}, '.'),:) = [];
files1(strcmpi({files1.name}, '..'),:) = [];
files1(files1.isdir) = [];

num_files = numel(files1);

im_all = cell(num_files,1);
z_all = zeros(num_files,1);
for n_file = 1:numel(files1)
    im1 = imread([path1 '\' files1(n_file).name]);
    [~, temp_fname, ~] = fileparts(files1(n_file).name);
    im_all{n_file} = im1;
    
    idx = strfind(temp_fname, '_z');
    if ~isempty(idx)
        tag1 = temp_fname(idx+2:end);
        
        tag_len = numel(tag1);
        
        tag_bool = false(tag_len,1);
        
        still_numeric = 1;
        n_char = 1;
        if tag1(n_char) == 45
            n_char = n_char + 1;
            sign1 = -1;
        else
            sign1 = 1;
        end
        
        while still_numeric
            if n_char <= tag_len
                if tag1(n_char) > 47 && tag1(n_char) < 58 % 45
                    tag_bool(n_char) = true;
                else
                    still_numeric = 0;
                end
            else
                still_numeric = 0;
            end
            n_char = n_char + 1;
        end

        tag2 = tag1(tag_bool);
        z_all(n_file) = str2double(tag2)*sign1;
    else
        z_all(n_file) = 0;
    end
end

app.app_main.pattern_editor_data.im_all = im_all;
app.app_main.pattern_editor_data.z_all = z_all;

f_sg_pp_update_bkg_im(app);

fprintf('Loaded %d pattern editor images\n', numel(z_all));
end