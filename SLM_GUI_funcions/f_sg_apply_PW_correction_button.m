function f_sg_apply_PW_correction_button(app)

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

f_sg_update_table_power(app)

end