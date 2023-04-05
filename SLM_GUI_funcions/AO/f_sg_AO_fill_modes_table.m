function f_sg_AO_fill_modes_table(app)

max_modes = app.MaxmodesEditField.Value;
W_lim = app.WeightlimitEditField.Value;
W_step = app.WeightstepEditField.Value;
ignore_modes_list = app.AO_ignore_modes_list;

num_modes = sum(1:(max_modes+1));
scan_modes = true(num_modes,1);
scan_modes(ignore_modes_list) = 0;

zernike_cell_list = cell(max_modes+1,1);
for mode = 0:max_modes
    n_modes = (-mode:2:mode)';
    m_modes = ones(mode+1,1)*mode;
    zernike_cell_list{mode+1} = [m_modes,n_modes]; 
end

zernike_table_list = cat(1, zernike_cell_list{:});

if app.AOignoredefocusmodesCheckBox.Value
    scan_modes(zernike_table_list(:,2) == 0) = 0;
end

app.ZernikeListTable.Data = [(round(1:num_modes)'),round(zernike_table_list), repmat([-W_lim, W_step, W_lim], num_modes, 1), logical(round(scan_modes))];

f_sg_AO_update_total_modes(app);

end