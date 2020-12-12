function f_SLM_gh_gen_holo(app, pattern)

% get reg
[m_idx, n_idx] = f_SLM_get_reg_deets(app, app.CurrentregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

app.current_SLM_region = app.CurrentregionDropDown.Value;

pointer = f_SLM_gh_gen_image(app, pattern, SLMm, SLMn);

% lut correction
pointer = f_SLM_lut_apply_corr(app, pointer, app.CurrentregionDropDown.Value);

holo_image = app.SLM_Image_gh_preview;
holo_image(m_idx,n_idx) = exp(1i*(f_SLM_poiner_to_im(app, pointer, SLMm, SLMn)-pi));

app.SLM_Image_plot.CData = angle(holo_image)+pi;
app.SLM_Image_gh_preview = holo_image;



end