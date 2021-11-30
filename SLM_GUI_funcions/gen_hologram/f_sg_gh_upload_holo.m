function f_sg_gh_upload_holo(app)

[~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

app.SLM_phase = app.SLM_gh_phase_preview;
app.SLM_phase_corr = app.SLM_gh_phase_preview;
app.SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(app.SLM_phase_corr(reg1.m_idx, reg1.n_idx), reg1);

f_sg_upload_image_to_SLM(app);

end