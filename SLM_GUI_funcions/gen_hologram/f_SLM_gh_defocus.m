function f_SLM_gh_defocus(app)

% get reg
[m_idx, n_idx] = f_SLM_get_reg_deets(app, app.CurrentregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

idx_reg = strcmpi(app.CurrentregionDropDown.Value, [app.region_list.name_tag]);
wavelength = app.region_list(idx_reg).wavelength*1e-9;

defocus_weight = app.DeficusWeightEditField.Value*1e-6;

defocus = f_SLM_DefocusPhase_YS(SLMm, SLMn,...
                app.SLM_ops.effective_NA,...
                app.SLM_ops.objective_RI,...
                wavelength*10)*defocus_weight;

defocus2=angle(sum(exp(1i*(defocus)),3))+pi;

holo_image = app.SLM_Image_gh_preview;
holo_image(m_idx,n_idx) = defocus2;

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image_gh_preview = holo_image;

end