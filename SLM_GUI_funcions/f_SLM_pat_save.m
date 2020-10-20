function f_SLM_pat_save(app)

idx1 = strcmpi(app.PatternlistDropDown.Value, [app.xyz_patterns.name_tag]);

if sum(idx1)
    pat1.name_tag = {app.PatternnameEditField.Value};
    pat1.SLM_roi = app.PatternROIDropDown.Value;
    pat1.xyz_pts = app.UIImagePhaseTable.Data;

    app.xyz_patterns(idx1) = pat1;
    
    f_SLM_pat_update(app, find(idx1));
else
    disp('Pattern save failed')
end

end