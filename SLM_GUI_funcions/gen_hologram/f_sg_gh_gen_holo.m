function f_sg_gh_gen_holo(app, pattern)

% get reg
[m_idx, n_idx] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

holo_phase_reg = f_sg_gh_gen_image(app, pattern, SLMm, SLMn);

% lut correction
%pointer = f_sg_lut_apply_corr(app, pointer, app.CurrentregionDropDown.Value);

app.SLM_gh_phase_preview(m_idx,n_idx) = angle(exp(1i*(holo_phase_reg-pi)));
app.SLM_phase_plot.CData = app.SLM_gh_phase_preview+pi;

end