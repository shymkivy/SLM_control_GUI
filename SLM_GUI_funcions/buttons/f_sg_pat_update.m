function f_sg_pat_update(app, manual_pattern_input)

if exist('manual_pattern_input', 'var')
    current_pat = manual_pattern_input;
else
    current_pat = find(strcmpi(app.PatterngroupDropDown.Value, {app.xyz_patterns.pat_name}));
end

pat1 = app.xyz_patterns(current_pat);

app.PatterngroupDropDown.Items = {app.xyz_patterns.pat_name};
app.PatterngroupDropDown.Value = pat1.pat_name;
app.GroupnameEditField.Value = pat1.pat_name;
app.CurrentregionDropDown.Items = {app.region_list.reg_name};
app.CurrentregionDropDown.Value = pat1.SLM_region;
app.UIImagePhaseTable.Data = pat1.xyz_pts;

end