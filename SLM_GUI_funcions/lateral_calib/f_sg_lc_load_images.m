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
    
    if app.InvertcoordsforbeadsCheckBox.Value
        input_coords = -input_coords;
    end
    
    input_coords = [input_coords, ones(size(input_coords,1),1)];
    
    lat_calib_all = struct();
    for n_file = 1:num_files
        im1 = imread([files_dir '\' file_names{n_file}], 'tif');
        
        lat_calib_all(n_file,:).X = input_coords(n_file,1);
        lat_calib_all(n_file,:).Y = input_coords(n_file,2);
        lat_calib_all(n_file,:).use_pt = input_coords(n_file,3);
        lat_calib_all(n_file,:).image = im1;
        lat_calib_all(n_file,:).input_X = input_coords(n_file,1);
        lat_calib_all(n_file,:).input_Y = input_coords(n_file,2);
    end
    
    app.data.lat_calib_all = lat_calib_all;
    app.data.input_coords = input_coords;
    
%     [~, sort_idx] = sort(input_coords(:,2));
%     input_coords = input_coords(sort_idx,:);
%     [~, sort_idx] = sort(input_coords(:,1));
%     input_coords = input_coords(sort_idx,:);
    
    t1 = table(input_coords(:,1), input_coords(:,2), input_coords(:,3));
    app.UITable.Data = t1;
end

end