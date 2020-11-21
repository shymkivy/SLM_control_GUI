function f_SLM_gh_gen_holo(app, pattern)

% get reg
[m_idx, n_idx] = f_SLM_gh_get_regmn(app);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

pointer = f_SLM_gh_gen_image(app, pattern, SLMm, SLMn);

% lut correction
pointer = f_SLM_lut_apply_corr(app, pointer, app.SelectRegionDropDownGH.Value);

holo_image = app.SLM_blank_im;
holo_image(m_idx,n_idx) = f_SLM_poiner_to_im(app, pointer, SLMm, SLMn);

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;
            
end