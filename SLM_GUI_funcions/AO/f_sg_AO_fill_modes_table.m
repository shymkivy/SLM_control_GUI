function f_sg_AO_fill_modes_table(app)

max_Zn = app.MaxZnEditField.Value;
W_lim = app.WeightlimitEditField.Value;
W_step = app.WeightstepEditField.Value;
ignore_modes_list = app.AO_ignore_modes_list;

Zn_all = 0:max_Zn;
num_modes = sum(Zn_all+1);

zernike_table_list = f_sg_get_zernike_mode_nm(Zn_all);

scan_modes = true(num_modes,1);
scan_modes(ignore_modes_list) = 0;

if app.AOignoresphericalmodeCheckBox.Value
    scan_modes(and(zernike_table_list(:,1) == 2, zernike_table_list(:,2) == 0)) = 0;
end

app.ZernikeListTable.Data = [(round(1:num_modes)'),round(zernike_table_list), repmat([-W_lim, W_step, W_lim], num_modes, 1), logical(round(scan_modes))];

f_sg_AO_update_total_modes(app);

end