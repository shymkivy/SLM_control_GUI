function f_SLM_pat_add(app)

idx1 = strcmpi(app.PatternnameEditField.Value, [app.xyz_patterns.name_tag]);

if ~sum(idx1)
    pat1.name_tag = {app.PatternnameEditField.Value};
    pat1.SLM_roi = app.PatternROIDropDown.Value;
    pat1.xyz_pts = app.UIImagePhaseTable.Data;

    app.xyz_patterns = [app.xyz_patterns; pat1];
    
    app.PatternlistDropDown.Items = [app.xyz_patterns.name_tag];
    app.PatternlistDropDown.Value = pat1.name_tag;
else
    disp('Pattern add failed');
end


end