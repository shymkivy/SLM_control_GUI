function f_SLM_pat_update(app, manual_pattern_input)

if exist('manual_pattern_input', 'var')
    current_pat = manual_pattern_input;
else
    current_pat = find(strcmpi(app.PatternlistDropDown.Value, [app.xyz_patterns.name_tag]));
end

pat1 = app.xyz_patterns(current_pat);

app.PatternlistDropDown.Items = [app.xyz_patterns.name_tag];
app.PatternlistDropDown.Value = pat1.name_tag;
app.PatternnameEditField.Value = pat1.name_tag{1};
app.PatternROIDropDown.Items = [app.SLM_roi_list.name_tag];
app.PatternROIDropDown.Value = pat1.SLM_roi;
app.UIImagePhaseTable.Data = pat1.xyz_pts;

end