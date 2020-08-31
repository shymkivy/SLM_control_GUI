function f_SLM_AO_update_total_modes(app)

zernike_table = app.ZernikeListTable.Data;
num_modes = size(zernike_table,1);
% cound number of all modes
weights_cell = cell(num_modes,1);
for n_mode = 1:num_modes
    weights_cell{n_mode} = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
end
app.TotalmodesEditField.Value = numel(cat(2,weights_cell{:}));
end