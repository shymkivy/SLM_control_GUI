function f_sg_upload_image_to_SLM(app)

% upload
app.SLM_image_pointer.Value = reshape(app.SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, app.SLM_image_pointer);

end