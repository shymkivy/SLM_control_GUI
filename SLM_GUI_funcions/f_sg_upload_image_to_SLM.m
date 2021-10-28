function f_sg_upload_image_to_SLM(app, add_ao)
% add AO correction if on

if ~exist('add_ao', 'var')
    add_ao = 1;
end

if add_ao
    AO_wf = f_sg_AO_get_correction(app);
    SLM_image = f_sg_AO_add_correction(app, app.SLM_Image, AO_wf);
    app.current_SLM_AO_Image = AO_wf;
else
    SLM_image = app.SLM_Image;
end

% add lut correction to pointer
[m_idx, n_idx, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

holo_phase = angle(SLM_image)+pi;
app.SLM_Image_pointer.Value = f_sg_im_to_pointer_lut_corr(holo_phase, reg1.lut_correction_data, m_idx, n_idx);
f_SLM_update(app.SLM_ops, app.SLM_Image_pointer);

end