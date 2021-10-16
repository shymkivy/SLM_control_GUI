function f_sg_pp_update_bkg_im(app)

current_z = app.ZdepthSpinner.Value;

z_all = [];
if isstruct(app.app_main.pattern_editor_data)
    if isfield(app.app_main.pattern_editor_data, 'z_all')
        z_all = app.app_main.pattern_editor_data.z_all;
    end
end
current_z_idx = (round(current_z) == z_all);

if sum(current_z_idx)
    im1 = app.app_main.pattern_editor_data.im_all{current_z_idx};
else
    im1 = [];
end

if ~app.BkgimageonButton.Value
    im1 = [];
end

app.data.plot_im.CData = im1;

end