function f_sg_AO_fill_modes_table(app)

max_Zn = app.MaxZnEditField.Value;
min_Zn = max(app.MinZnEditField.Value, 0);
W_lim = app.WeightrangeEditField.Value;
W_num_steps = app.NumwstepsEditField.Value;
W_step = W_lim*2/(W_num_steps-1);
ignore_modes_list = app.AO_ignore_modes_list;

Zn_all = 0:max_Zn;
num_modes = sum(Zn_all+1);

zernike_table_list = f_sg_get_zernike_mode_nm(Zn_all);

scan_modes = true(num_modes,1);
scan_modes(ignore_modes_list) = 0;

if app.AOignoresphericalmodeCheckBox.Value
    scan_modes(and(zernike_table_list(:,1) == 2, zernike_table_list(:,2) == 0)) = 0;
end

if app.AOignoreallsphericalCheckBox.Value
    scan_modes(zernike_table_list(:,2) == 0) = 0;
end

tab_data = [(round(1:num_modes)'),round(zernike_table_list), repmat([W_lim, W_step, W_num_steps], num_modes, 1), logical(round(scan_modes))];

app.ZernikeListTable.Data = tab_data(zernike_table_list(:,1) >= min_Zn,:);

f_sg_AO_update_total_modes(app);

end