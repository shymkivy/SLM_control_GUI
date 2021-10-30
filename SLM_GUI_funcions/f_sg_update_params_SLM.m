function f_sg_update_params_SLM(app)

was_on = app.SLM_ops.SDK_created;

if app.SLM_ops.SDK_created
    app.SLM_ops = f_SLM_close(app.SLM_ops);
    if ~app.SLM_ops.SDK_created
        app.ActivateSLMLamp.Color = [0.80,0.80,0.80]; %[0.00,1.00,0.00];
        app.ActivateSLMButton.Value = 0;
    end
end

app.SLM_ops.SLM_type = app.SLMtypeDropDown.Value;

current_SLM = app.SLM_ops.SLM_type;
f_SLM_GUI_default_ops(app);
app.SLM_ops.SLM_type = current_SLM;

f_sg_load_default_ops(app);
f_sg_load_calibration(app);
f_sg_reg_update(app);

if was_on
    app.SLM_ops = f_SLM_initialize(app.SLM_ops);
    if app.SLM_ops.SDK_created
        app.ActivateSLMLamp.Color = [0.00,1.00,0.00];
        app.ActivateSLMButton.Value = 1;
    end
end

end