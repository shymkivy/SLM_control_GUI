function f_sg_update_W_est(app)

tab_data = app.UIImagePhaseTable.Data;

I_targ = tab_data.I_targ;

if app.I_targI22PCheckBox.Value
    I_targ1P = sqrt(I_targ);
else
    I_targ1P = I_targ;
end

tab_data.W_est = sqrt(I_targ1P);

app.UIImagePhaseTable.Data = tab_data;

end