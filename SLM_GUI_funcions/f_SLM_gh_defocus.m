function f_SLM_gh_defocus(app)

% get roi
[m_idx, n_idx] = f_SLM_gh_get_roimn(app);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

idx_roi = strcmpi(app.SelectROIDropDownGH.Value, [app.SLM_roi_list.name_tag]);
wavelength = app.SLM_roi_list(idx_roi).wavelength*10e-9;

defocus_weight = app.DeficusWeightEditField.Value*10e-6;

defocus = f_SLM_DefocusPhase_YS(SLMm, SLMn,...
                app.SLM_ops.objective_NA,...
                app.SLM_ops.objective_RI,...
                wavelength*10)*defocus_weight;

defocus=angle(sum(exp(1i*(defocus-pi)),3))+pi;

holo_image = app.SLM_blank_im;
holo_image(m_idx,n_idx) = defocus;

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;

end