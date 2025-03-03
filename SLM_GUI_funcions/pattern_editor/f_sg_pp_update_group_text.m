function f_sg_pp_update_group_text(app)

if isfield(app.app_main.xyz_patterns, 'groups_data')

    pat_idx = strcmpi({app.app_main.xyz_patterns.pat_name}, app.PatterngroupEditField.Value);
    lists_all = app.app_main.xyz_patterns(pat_idx).groups_data;
    
    num_lines = numel(lists_all);
    if num_lines
        line_text = cell(num_lines,1);
        for n_ln = 1:num_lines
            line_text{n_ln} = num2str(lists_all{n_ln}');
        end
        app.ListgroupsTextArea.Value = line_text;
    else
        app.ListgroupsTextArea.Value = {''};
    end

    tab_data = app.app_main.UIImagePhaseTable.Data;

    group_tags_all = cell(numel(tab_data.Idx),1);
    for n_gr = 1:numel(lists_all)
        idx1 = find(sum(lists_all{n_gr} == tab_data.Idx',1));
        for n_idx = 1:numel(idx1)
            if ~numel(group_tags_all{idx1(n_idx)})
                group_tags_all{idx1(n_idx)} = num2str(n_gr);
            else
                group_tags_all{idx1(n_idx)} = [group_tags_all{idx1(n_idx)} ',' num2str(n_gr)];
            end
        end
    end
    
    app.data.group_tags = group_tags_all;
    
end

end