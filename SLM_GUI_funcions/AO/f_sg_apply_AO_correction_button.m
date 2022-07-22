function f_sg_apply_AO_correction_button(app)

%% compute all corrections (also maybe not needed, only during updates?)
for n_reg = 1:numel(app.region_obj_params) 
    app.region_obj_params(n_reg).AO_wf = f_sg_AO_compute_wf(app, app.region_obj_params(n_reg));
end

%% reupload upload current coord with correction update
coord = app.GUI_buffer.current_SLM_coord;
f_sg_xyz_upload_coord(app, coord);

%%
if app.ApplyAOcorrectionButton.Value
    app.InitializeAOLamp.Color = [0.00,1.00,0.00];
else
    app.InitializeAOLamp.Color = [0.80,0.80,0.80];
    app.current_SLM_AO_Image = [];
end

end