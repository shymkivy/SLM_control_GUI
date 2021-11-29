function f_sg_upload_image_to_SLM(app)

%% apply lut correction for current region
% from app.SLM_phase_corr to app.SLM_phase_corr_lut
f_sg_lut_apply_corr(app);

%% upload
app.SLM_image_pointer.Value = reshape(app.SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, app.SLM_image_pointer);

end