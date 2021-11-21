function f_sg_AO_update_total_modes(app)

zernike_table = app.ZernikeListTable.Data;
zernike_table = zernike_table(logical(zernike_table(:,7)),:);

num_modes = size(zernike_table,1);
% cound number of all modes
weights_cell = cell(num_modes,1);
for n_mode = 1:num_modes
    weights_cell{n_mode} = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
end

total_modes = numel(cat(2,weights_cell{:}));
if app.InsertrefimageinscansCheckBox.Value
    total_modes = total_modes + num_modes;
end

total_modes = total_modes * app.ScanspermodeEditField.Value;

app.NumscanvolumesEditField.Value = total_modes;
app.NumscanframesEditField.Value = total_modes*app.ScansperVolZEditField.Value;
app.NumscanframesOpEditField.Value = total_modes*app.NumiterationsSpinner.Value + 1 + sum((1:app.NumiterationsSpinner.Value)+1)*app.ScanspermodeEditField.Value;
end