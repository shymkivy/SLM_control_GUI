function f_sg_xyz_button_add_to_holo(app)

if isempty(app.UIImagePhaseTable.Data)
    idx = 1;
else
    idx = numel(app.UIImagePhaseTable.Data.Idx)+1;
end

coord = f_sg_mpl_get_coords(app, 'custom');

new_row = f_sg_initialize_tabxyz(app, 1);

new_row.Idx = idx;
new_row.Pattern = app.PatternnumberEditField.Value;
new_row.X = coord.xyzp(1);
new_row.Y = coord.xyzp(2);
new_row.Z = coord.xyzp(3);
new_row.Weight = coord.weight;
               
app.UIImagePhaseTable.Data = [app.UIImagePhaseTable.Data; new_row];

f_sg_update_table_power(app, app.PatternnumberEditField.Value)

end
