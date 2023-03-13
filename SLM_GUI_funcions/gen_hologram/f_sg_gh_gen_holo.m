function f_sg_gh_gen_holo(app, pattern)

% get reg
reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

holo_phase_reg = f_sg_gh_gen_image(app, pattern, reg1);

holo_phase = holo_phase_reg-pi;

if app.ApplyZOsuppressionButton.Value
    holo_phase = f_sg_apply_ZO_corr(holo_phase, reg1);
end

app.SLM_gh_phase_preview(reg1.m_idx, reg1.n_idx) = holo_phase;
app.SLM_phase_plot.CData = app.SLM_gh_phase_preview+pi;

end