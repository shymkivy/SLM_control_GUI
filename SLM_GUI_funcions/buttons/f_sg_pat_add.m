function f_sg_pat_add(app)

idx1 = strcmpi(app.GroupnameEditField.Value, {app.xyz_patterns.pat_name});

if ~sum(idx1)
    pat1.pat_name = app.GroupnameEditField.Value;
    pat1.xyz_pts = app.UIImagePhaseTable.Data;
    pat1.SLM_region = app.CurrentregionDropDown.Value;

    app.xyz_patterns = [app.xyz_patterns, pat1];
    
    app.PatterngroupDropDown.Items = {app.xyz_patterns.pat_name};
    app.PatterngroupDropDown.Value = pat1.pat_name;
    app.PatternDropDownCtr.Items = [{'None'}, app.xyz_patterns.pat_name];
    app.PatternDropDownAI.Items = [{'None'}, app.xyz_patterns.pat_name];
else
    disp('Pattern add failed, make a unique name');
end


end