function f_sg_gh_gen_holo(app, pattern)

% get reg
[m_idx, n_idx] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

pointer = f_sg_gh_gen_image(app, pattern, SLMm, SLMn);

% lut correction
%pointer = f_sg_lut_apply_corr(app, pointer, app.CurrentregionDropDown.Value);

holo_image = app.SLM_Image_gh_preview;
holo_image(m_idx,n_idx) = exp(1i*(f_sg_poiner_to_im(pointer, SLMm, SLMn)-pi));

app.SLM_Image_plot.CData = angle(holo_image)+pi;
app.SLM_Image_gh_preview = holo_image;

end