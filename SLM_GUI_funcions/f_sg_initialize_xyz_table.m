function f_sg_initialize_xyz_table(app)

Varnames = {'Idx', 'Pattern', 'X', 'Y', 'Z', 'I_targ', 'I_est', 'W_set', 'W_est'};
app.GUI_ops.table_var_names = Varnames;
xyz_patterns(1).pat_name = 'Multiplane';
tab_data = f_sg_initialize_tabxyz(app, 0);
xyz_patterns(1).xyz_pts = tab_data;
xyz_patterns(1).SLM_region = app.CurrentregionDropDown.Value;

if isfield(app.SLM_ops, 'xyz_patterns')
    temp_pat = app.SLM_ops.xyz_patterns;
    if ~isempty(temp_pat)
        reg_exists = false(numel(temp_pat),1);
        for n_pat = 1:numel(temp_pat)
            reg_exists(n_pat) = sum(strcmpi(temp_pat(n_pat).SLM_region, {app.region_list.reg_name}));
        end
        temp_pat(~reg_exists) = [];
        if ~isempty(temp_pat)
            for n_pat = 1:numel(temp_pat)
                if ~isempty(temp_pat(n_pat).xyz_pts)
                    [num_row, ~] = size(temp_pat(n_pat).xyz_pts);
                    tab_data2 = f_sg_initialize_tabxyz(app, num_row);
                    xyz1 = temp_pat(n_pat).xyz_pts;
                    tab_data2.X = xyz1(:,1);
                    tab_data2.Y = xyz1(:,2);
                    tab_data2.Z = xyz1(:,3);
                else
                    tab_data2 = tab_data;
                end
                temp_pat(n_pat).xyz_pts = tab_data2;
            end
            xyz_patterns = temp_pat;
        end
    end
end
app.xyz_patterns = xyz_patterns;

end