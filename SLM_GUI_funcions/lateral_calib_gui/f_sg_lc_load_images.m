function f_sg_lc_load_images(app)

if isempty(app.imagedirEditField.Value)
    uialert(app.UIFigure,'Directory not found','Rafa: add directory of images');
else
    %%
    files_dir = app.imagedirEditField.Value;

    % for 20X zoom 1 256 pixel/um ratio
    %%
    file_list = dir([files_dir, '\' '*.tif']);
    num_files = numel(file_list);
    file_names = cell(num_files,1);
    for n_file = 1:num_files
        file_names{n_file} = file_list(n_file).name;
    end
       
    input_coords = zeros(num_files,3);      % (x,y)  coordinates for each file
    isaxial = false(num_files,1);
    for n_file = 1:num_files
        
        temp_str = lower(file_names{n_file});
        
        %startIndex = regexp(temp_str,'x\d')
        
        input_coords(n_file,1) = f_sg_lc_get_coord_from_string(temp_str, 'x');
        input_coords(n_file,2) = f_sg_lc_get_coord_from_string(temp_str, 'y');
        input_coords(n_file,3) = f_sg_lc_get_coord_from_string(temp_str, 'z');
        
        axial1 = strfind(temp_str,'axial');
        if axial1
            isaxial(n_file) = 1;
        end
        
    end
    
    %% sorting
    [~, z_sort] = sort(input_coords(isaxial,3));
    temp_data = input_coords(isaxial,:);
    input_coords_ax = temp_data(z_sort,:);
    temp_data = file_names(isaxial);
    file_names_ax = temp_data(z_sort);
    
    isy = logical(input_coords(:,2));
    isx = ~logical(isaxial+isy);
    
    [~, x_sort] = sort(input_coords(isx,1));
    temp_data = input_coords(isx,:);
    input_coords_x = temp_data(x_sort,:);
    temp_data = file_names(isx);
    file_names_x = temp_data(x_sort);
    
    [~, y_sort] = sort(input_coords(isy,2));
    temp_data = input_coords(isy,:);
    input_coords_y = temp_data(y_sort,:);
    temp_data = file_names(isy);
    file_names_y = temp_data(y_sort);
    
    input_coords = [input_coords_ax; input_coords_x; input_coords_y];
    file_names = [file_names_ax; file_names_x; file_names_y];
    
    %%
    lat_calib_all = struct();
    for n_file = 1:num_files
        im1 = imread([files_dir '\' file_names{n_file}], 'tif');
        
        lat_calib_all(n_file,:).X = input_coords(n_file,1);
        lat_calib_all(n_file,:).Y = input_coords(n_file,2);
        lat_calib_all(n_file,:).Z = input_coords(n_file,3);
        lat_calib_all(n_file,:).image = im1;
%         lat_calib_all(n_file,:).input_X = input_coords(n_file,1);
%         lat_calib_all(n_file,:).input_Y = input_coords(n_file,2);
%         lat_calib_all(n_file,:).input_Z = input_coords(n_file,3);
    end
    
    app.data.lat_calib_all = lat_calib_all;
    app.data.input_coords = input_coords;
    
%     [~, sort_idx] = sort(input_coords(:,2));
%     input_coords = input_coords(sort_idx,:);
%     [~, sort_idx] = sort(input_coords(:,1));
%     input_coords = input_coords(sort_idx,:);
    
    t1 = table(input_coords(:,1), input_coords(:,2), input_coords(:,3), ~isaxial, isaxial);
    app.UITable.Data = t1;
end
end