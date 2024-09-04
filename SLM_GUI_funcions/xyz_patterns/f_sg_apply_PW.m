function f_sg_apply_PW(app)

value = app.ApplyPWtoI_targButton.Value;

tab_data = app.UIImagePhaseTable.Data;
reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
intens_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, [tab_data.X, tab_data.Y]);

if value
    % tuurned on
    I_targ_new = tab_data.I_targ./intens_corr;
    I_targ_new = I_targ_new/min(I_targ_new);
else
    I_targ_new = tab_data.I_targ.*intens_corr;
    I_targ_new = I_targ_new/min(I_targ_new);
end

tab_data.I_targ = I_targ_new;

app.UIImagePhaseTable.Data = tab_data;

end