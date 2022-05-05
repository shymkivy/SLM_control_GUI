function f_sg_pp_update_group_text(app)

if isfield(app.app_main.xyz_patterns, 'groups_data')

    pat_idx = strcmpi({app.app_main.xyz_patterns.pat_name}, app.app_main.PatterngroupDropDown.Value);
    lists_all = app.app_main.xyz_patterns(pat_idx).groups_data;
    
    num_lines = numel(lists_all);
    if num_lines
        line_text = cell(num_lines,1);
        for n_ln = 1:num_lines
            line_text{n_ln} = num2str(lists_all{n_ln}');
        end
        app.ListgroupsTextArea.Value = line_text;
    end
end

end