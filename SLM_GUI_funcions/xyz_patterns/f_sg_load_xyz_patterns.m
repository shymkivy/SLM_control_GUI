function f_sg_load_xyz_patterns(app)
% Load xyz pattern

    [file, location, ~] = uigetfile();
    filepath = strcat([location, file]);

    load(filepath, 'XYZ_data');

    pattern = struct();
    pattern.pat_name = XYZ_data.pattern;
    pattern.xyz_pts = XYZ_data.coords_table;
    pattern.SLM_region = XYZ_data.region;

    app.xyz_patterns = [app.xyz_patterns, pattern];
    app.PatterngroupDropDown.Items = {app.xyz_patterns.pat_name}; 
    app.CurrentregionDropDown.Value = pattern.SLM_region;
    app.UIImagePhaseTable.Data = pattern.xyz_pts;
    app.PatternDropDownCtr.Items = [{'None'}, app.xyz_patterns.pat_name];
    app.PatternDropDownAI.Items = [{'None'}, app.xyz_patterns.pat_name];

end
