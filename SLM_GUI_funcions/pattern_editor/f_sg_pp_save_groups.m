function f_sg_pp_save_groups(app)

text_all = app.ListgroupsTextArea.Value;
num_lines = numel(text_all);

lists_all = cell(num_lines,1);
for n_ln = 1:num_lines
    lists_all{n_ln} = unique(f_str_to_array(text_all{n_ln}));
end

pat_idx = strcmpi({app.app_main.xyz_patterns.pat_name}, app.PatterngroupEditField.Value);
app.app_main.xyz_patterns(pat_idx).groups_data = lists_all;

f_sg_pp_update_group_text(app);
f_sg_pp_update_pat_plot(app);

end