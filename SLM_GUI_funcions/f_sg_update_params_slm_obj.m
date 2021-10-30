function f_sg_update_params_slm_obj(app)

app.SLM_ops.SLM_type = app.SLMtypeDropDown.Value;

f_sg_load_default_ops(app);
f_sg_load_calibration(app);
f_sg_reg_update(app)

end