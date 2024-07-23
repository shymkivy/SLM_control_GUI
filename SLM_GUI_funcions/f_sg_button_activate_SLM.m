function f_sg_button_activate_SLM(app)

if app.ActivateSLMButton.Value
    app.SLM_ops = f_SLM_initialize(app.SLM_ops);
    if app.SLM_ops.sdkObj.SDK_created
        app.ActivateSLMLamp.Color = [0.00,1.00,0.00];
    else
        app.ActivateSLMButton.Value = 0;
    end
else
    app.SLM_ops = f_SLM_close(app.SLM_ops);
    app.ActivateSLMLamp.Color = [0.80,0.80,0.80];
end

end