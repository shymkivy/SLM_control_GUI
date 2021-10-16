function f_sg_gh_custom_phase_browse(app)

[fname,fpath] = uigetfile([app.SLM_ops.custom_phase_dir '\*.bmp;*.png;*.jpeg;*.tiff;*.tif;*.gif;*.mat'], 'Select custom phase file');

if fname
    app.ImagepathEditField.Value = [fpath fname];
end

end