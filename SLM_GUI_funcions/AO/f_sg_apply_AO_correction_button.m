function f_sg_apply_AO_correction_button(app)

for n_reg = 1:numel(app.region_list) 
    app.region_list(n_reg).AO_wf = f_sg_AO_compute_wf(app, app.region_list(n_reg));
end

f_sg_upload_image_to_SLM(app);

if app.ApplyAOcorrectionButton.Value
    app.InitializeAOLamp.Color = [0.00,1.00,0.00];
else
    app.InitializeAOLamp.Color = [0.80,0.80,0.80];
    app.current_SLM_AO_Image = [];
end


end