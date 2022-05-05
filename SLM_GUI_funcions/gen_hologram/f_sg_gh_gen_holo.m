function f_sg_gh_gen_holo(app, pattern)

% get reg
reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

holo_phase_reg = f_sg_gh_gen_image(app, pattern, sum(reg1.m_idx), sum(reg1.n_idx));

app.SLM_gh_phase_preview(reg1.m_idx, reg1.n_idx) = angle(exp(1i*(holo_phase_reg-pi)));
app.SLM_phase_plot.CData = app.SLM_gh_phase_preview+pi;

end