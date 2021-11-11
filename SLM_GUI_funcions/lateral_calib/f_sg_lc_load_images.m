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
    for n_file = 1:num_files
        
        temp_str = lower(file_names{n_file});
        
        x_loc = strfind(temp_str,'_x');
        if x_loc
            start1 = x_loc+2;
            if temp_str(start1) == '-'
                start1 = start1 + 1;
                sign1 = -1;
            else
                sign1 = 1;
            end
            end1 = start1;
            
            while and(temp_str(end1+1) >= '0', temp_str(end1+1) <= '9')
                end1 = end1 + 1;
            end
            input_coords(n_file,1) = str2double(temp_str(start1:end1))*sign1;
        end
        
        y_loc = strfind(temp_str,'_y');
        if y_loc
            start1 = y_loc+2;
            if temp_str(start1) == '-'
                start1 = start1 + 1;
                sign1 = -1;
            else
                sign1 = 1;
            end
            end1 = start1;
            
            while and(temp_str(end1+1) >= '0', temp_str(end1+1) <= '9')
                end1 = end1 + 1;
            end
            input_coords(n_file,2) = str2double(temp_str(start1:end1))*sign1;
        end
        
        z_loc = strfind(temp_str,'_z');
        if z_loc
            start1 = z_loc+2;
            if temp_str(start1) == '-'
                start1 = start1 + 1;
                sign1 = -1;
            else
                sign1 = 1;
            end
            end1 = start1;
            
            while and(temp_str(end1+1) >= '0', temp_str(end1+1) <= '9')
                end1 = end1 + 1;
            end
            input_coords(n_file,3) = str2double(temp_str(start1:end1))*sign1;
        end
        
    end
    
    if app.InvertcoordsforbeadsCheckBox.Value
        input_coords = -input_coords;
    end
    
    input_coords = [input_coords, zeros(size(input_coords,1),1)];
    
    lat_calib_all = struct();
    for n_file = 1:num_files
        im1 = imread([files_dir '\' file_names{n_file}], 'tif');
        
        lat_calib_all(n_file,:).X = input_coords(n_file,1);
        lat_calib_all(n_file,:).Y = input_coords(n_file,2);
        lat_calib_all(n_file,:).Z = input_coords(n_file,3);
        lat_calib_all(n_file,:).use_pt = input_coords(n_file,4);
        lat_calib_all(n_file,:).image = im1;
        lat_calib_all(n_file,:).input_X = input_coords(n_file,1);
        lat_calib_all(n_file,:).input_Y = input_coords(n_file,2);
        lat_calib_all(n_file,:).input_Z = input_coords(n_file,3);
    end
    
    app.data.lat_calib_all = lat_calib_all;
    app.data.input_coords = input_coords;
    
%     [~, sort_idx] = sort(input_coords(:,2));
%     input_coords = input_coords(sort_idx,:);
%     [~, sort_idx] = sort(input_coords(:,1));
%     input_coords = input_coords(sort_idx,:);
    
    t1 = table(input_coords(:,1), input_coords(:,2), input_coords(:,3), input_coords(:,4));
    app.UITable.Data = t1;
end

end