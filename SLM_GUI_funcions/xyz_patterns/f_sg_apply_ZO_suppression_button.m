function f_sg_apply_ZO_suppression_button(app)


for n_reg = 1:numel(app.region_obj_params)
    app.region_obj_params(n_reg).pw_corr_data = f_sg_compute_pw_corr(app, app.region_obj_params(n_reg));
end
if app.ApplyPWcorrectionButton.Value
    app.PWcorrectionLamp.Color = [0,1,0];
    pause(0.05);
else
    app.PWcorrectionLamp.Color = [0.80,0.80,0.80];
    pause(0.05);
end

value = app.ApplyZOsuppressionButton.Value;



%% reupload upload current coord with correction update
coord = app.GUI_buffer.current_SLM_coord;
f_sg_xyz_upload_coord(app, coord);

%%
if app.ApplyZOsuppressionButton.Value
    app.ZOsuppressionLamp.Color = [0.00,1.00,0.00];
else
    app.ZOsuppressionLamp.Color = [0.80,0.80,0.80];
end


end