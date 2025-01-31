function f_sg_apply_PW_correction_button(app)
% point weignt corrections

if app.ApplyPWcorrectionButton.Value
    app.PWcorrectionLamp.Color = [0,1,0];
    pause(0.05);
else
    if app.ApplyPWcorrectionButton.Value
        tab_data = app.UIImagePhaseTable.Data;
        reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
        intens_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, [tab_data.X, tab_data.Y]);

        I_targ_new = tab_data.I_targ.*intens_corr;
        I_targ_new = I_targ_new/min(I_targ_new);
        
        tab_data.I_targ = I_targ_new;

        app.UIImagePhaseTable.Data = tab_data;
        
        app.ApplyPWcorrectionButton.Value = 0;
    end
    app.PWcorrectionLamp.Color = [0.80,0.80,0.80];
    pause(0.05);
end

for n_reg = 1:numel(app.region_obj_params)
    app.region_obj_params(n_reg).pw_corr_data = f_sg_compute_pw_corr(app, app.region_obj_params(n_reg));
end
%f_sg_update_table_power(app);

end