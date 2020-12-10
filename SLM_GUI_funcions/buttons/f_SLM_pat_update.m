function f_SLM_pat_update(app, manual_pattern_input)

if exist('manual_pattern_input', 'var')
    current_pat = manual_pattern_input;
else
    current_pat = find(strcmpi(app.PatterngroupDropDown.Value, [app.xyz_patterns.name_tag]));
end

pat1 = app.xyz_patterns(current_pat);

app.PatterngroupDropDown.Items = [app.xyz_patterns.name_tag];
app.PatterngroupDropDown.Value = pat1.name_tag;
app.GroupnameEditField.Value = pat1.name_tag{1};
app.CurrentregionDropDown.Items = [app.region_list.name_tag];
app.CurrentregionDropDown.Value = pat1.SLM_region;
app.UIImagePhaseTable.Data = pat1.xyz_pts;

end