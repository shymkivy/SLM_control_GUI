function f_sg_xyz_button_add_to_holo(app)

tab_data = app.UIImagePhaseTable.Data;

if isempty(tab_data)
    current_idx = 1;
else
    bd_idx = 999;
    current_idx = max(tab_data.Idx(tab_data.Idx ~= bd_idx))+1;
end

coord = f_sg_mpl_get_coords(app, 'custom');
pat_num = f_str_to_array(app.PatternnumberEditField.Value);

num_rows = numel(coord.weight);
new_row = f_sg_initialize_tabxyz(app, 1);

if num_rows > 1
    if numel(pat_num) == 1
        pat_num = ones(num_rows,1)*pat_num;
    else
        if pat_num < num_rows
            pat_num = ones(num_rows,1)*pat_num(1);
            fprintf('pattern numbers indicated dont match rows, used n=%d first\n', pat_num(1));
        else
            if pat_num > num_rows
                fprintf('pattern numbers indicated dont match rows, used first n=%d\n', num_rows);
            end
            pat_num = pat_num(1:num_rows);
        end
    end
end
updates = 0;

if num_rows == numel(pat_num)
    for n_row = 1:num_rows
        if sum(sum(abs([tab_data.Pattern, tab_data.X, tab_data.Y, tab_data.Z] - [pat_num(n_row), coord.xyzp(n_row,:)]),2) == 0)
            fprintf('coordinate pat %d (%.2f, %.2f, %.2f) already exists\n', pat_num(n_row), coord.xyzp(n_row,1), coord.xyzp(n_row,2), coord.xyzp(n_row,3))
        else
            new_row.Idx = current_idx;
            new_row.Pattern = pat_num(n_row);
            new_row.X = coord.xyzp(n_row,1);
            new_row.Y = coord.xyzp(n_row,2);
            new_row.Z = coord.xyzp(n_row,3);
            new_row.W_set = coord.weight_set(n_row);
            new_row.W_est = coord.weight(n_row);
            
            current_idx = current_idx + 1;
            
            tab_data = [tab_data; new_row];
            updates = updates + 1;
        end
    end
else
    disp('Number of patterns and rows did not match')
end

if updates
    app.UIImagePhaseTable.Data = tab_data;
end
end
