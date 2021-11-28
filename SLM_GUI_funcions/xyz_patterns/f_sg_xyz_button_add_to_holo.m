function f_sg_xyz_button_add_to_holo(app)

tab_data = app.UIImagePhaseTable.Data;

if isempty(tab_data)
    idx = 1;
else
    idx = size(tab_data,1)+1;
    %tab_data(:,1) = 1:(idx-1);
end

coord = f_sg_mpl_get_coords(app, 'custom');

new_row = array2table([idx, app.PatternnumberEditField.Value,...
                    coord.xyzp, coord.weight]);
                
new_row.Properties.VariableNames = app.GUI_ops.table_var_names;
                
app.UIImagePhaseTable.Data = [tab_data; new_row];
                                    
end