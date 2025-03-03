function f_sg_pp_init_z_depth_spinner(app)
% Initializes Z-Depth Spinner such that it contains both an integer index of loaded images 
% and an associated vector of labeled z-depths. This supports the implementation of a variable step spinner,
% which is not supported out-of-the-box by MATLAB

if isstruct(app.app_main.pattern_editor_data)
    if isfield(app.app_main.pattern_editor_data, 'xyz_all')
        z_all = app.app_main.pattern_editor_data.xyz_all(:,3);
        app.ZdepthSpinner.UserData = z_all;
        lower_limit = min(z_all);
        upper_limit = max(z_all);
        app.ZdepthSpinner.Limits = [lower_limit, upper_limit];
    end
end
