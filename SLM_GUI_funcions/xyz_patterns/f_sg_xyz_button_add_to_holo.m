function f_sg_xyz_button_add_to_holo(app)

if isempty(app.UIImagePhaseTable.Data)
    idx = 1;
else
    idx = max(app.UIImagePhaseTable.Data.Idx)+1;
end

coord = f_sg_mpl_get_coords(app, 'custom');

num_rows = numel(coord.weight);
new_row = f_sg_initialize_tabxyz(app, num_rows);

num_pats = f_str_to_array(app.PatternnumberEditField.Value);
if num_rows > 1
    if num_pats == 1
        num_pats = ones(num_rows,1)*num_pats;
    else
        if num_pats < num_rows
            num_pats = ones(num_rows,1)*num_pats(1);
            fprintf('pattern numbers indicated dont match n=%d\n', num_rows);
        else
            num_pats = num_pats(1:num_rows);
        end
    end
end

%%
new_row.Idx = (1:num_rows)' + idx - 1;
new_row.Pattern = num_pats;
new_row.X = coord.xyzp(:,1);
new_row.Y = coord.xyzp(:,2);
new_row.Z = coord.xyzp(:,3);
new_row.Weight = coord.weight;
               
app.UIImagePhaseTable.Data = [app.UIImagePhaseTable.Data; new_row];

end
