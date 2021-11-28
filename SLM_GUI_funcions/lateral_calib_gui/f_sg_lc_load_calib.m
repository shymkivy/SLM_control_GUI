function f_sg_lc_load_calib(app)

fname = app.calibfilenameEditField.Value;
fpath = [app.imagedirEditField.Value '/' fname];

if exist(fpath, 'file')
    load1 = load(fpath);
    
    xyz_affine_calib = load1.xyz_affine_calib;
    
    %islateral = app.UITable.Data(:,4).Variables;
    
    input_data = app.data.input_coords;
    num_coords_data = size(input_data,1);
    islateral = logical(app.UITable.Data(:,4).Variables);
    isaxial = logical(app.UITable.Data(:,5).Variables);

    
    if isfield(app.data, 'zero_ord_coords')
        zero_ord_coords = app.data.zero_ord_coords;
    else
        zero_ord_coords = zeros(num_coords_data,2);
    end
    if isfield(app.data, 'first_ord_coords')
        first_ord_coords = app.data.first_ord_coords;
    else
        first_ord_coords = zeros(num_coords_data,2);
    end
    
    
    input_load = xyz_affine_calib.input_coords;
    
    %input_load(:,1:2) = -input_load(:,1:2);
    
    if isfield(xyz_affine_calib, 'isaxial')
        axial_idx_load = find(xyz_affine_calib.isaxial);
        
        input_axial = input_data(isaxial,:);
        axial_idx = find(isaxial);
        
        num_coords_load = numel(axial_idx_load);
        % for every load find corresponding im
        for n_coord = 1:num_coords_load
            load_idx = axial_idx_load(n_coord);
            [~, save_idx] = min(sum((input_load(load_idx,:) - input_axial).^2,2));
            zero_ord_coords(axial_idx(save_idx),:) = xyz_affine_calib.zero_ord_coords(load_idx,:);
            first_ord_coords(axial_idx(save_idx),:) = xyz_affine_calib.first_ord_coords(load_idx,:);
        end
    end
    
    input_lateral = input_data(islateral,:);
    lateral_idx = find(islateral);
    if isfield(xyz_affine_calib, 'islateral')
        lateral_idx_load = find(xyz_affine_calib.islateral);
        
        
        
        num_coords_load = numel(lateral_idx_load);
        for n_coord = 1:num_coords_load
            load_idx = lateral_idx_load(n_coord);
            [~, save_idx] = min(sum((input_load(load_idx,:) - input_lateral).^2,2));
            zero_ord_coords(lateral_idx(save_idx),:) = xyz_affine_calib.zero_ord_coords(load_idx,:);
            first_ord_coords(lateral_idx(save_idx),:) = xyz_affine_calib.first_ord_coords(load_idx,:);
        end
    else
        num_coords_load = size(input_load,1);
        if size(input_load,2) ~= 3
            input_load = [input_load(:,1:2), zeros(num_coords_load,1)];
        end
        %idx_seq = zeros(num_coords_load,1);
        for n_coord = 1:num_coords_load
            [~, save_idx] = min(abs(sum((input_load(n_coord,:) - input_lateral).^2,2)));
            if numel(save_idx) == 1
                zero_ord_coords(lateral_idx(save_idx),:) = xyz_affine_calib.zero_ord_coords(n_coord,:);
                first_ord_coords(lateral_idx(save_idx),:) = xyz_affine_calib.first_ord_coords(n_coord,:);
                %idx_seq(n_coord) = idx1;
            end
        end
    end
    
    app.data.zero_ord_coords = zero_ord_coords;
    app.data.first_ord_coords = first_ord_coords;
    %app.data.input_coords = xyz_affine_calib.input_coords;
    
    % bug in slm gui before 11/2021
    %app.data.y_flip_bug = 1;
    if isfield(xyz_affine_calib, 'y_flip_bug')
        app.data.y_flip_bug = xyz_affine_calib.y_flip_bug;
    end
    
    if isfield(xyz_affine_calib, 'calib_ops')
        if isfield(xyz_affine_calib.calib_ops, 'invert_for_beads')
            app.InvertcoordsforbeadsCheckBox.Value = xyz_affine_calib.calib_ops.invert_for_beads;
        end
        if isfield(xyz_affine_calib.calib_ops, 'zoom')
            app.ZoomEditField.Value = xyz_affine_calib.calib_ops.zoom;
        end
        if isfield(xyz_affine_calib.calib_ops, 'fov_size')
            app.FOVszieumEditField.Value = xyz_affine_calib.calib_ops.fov_size;
        end
        
    end
else
    disp('File does not exist')
end

end