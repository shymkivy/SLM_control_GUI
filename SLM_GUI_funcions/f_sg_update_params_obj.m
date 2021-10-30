function f_sg_update_params_obj(app)

current_SLM = app.SLM_ops.SLM_type;
f_SLM_GUI_default_ops(app);
app.SLM_ops.SLM_type = current_SLM;

f_sg_load_default_ops(app);
f_sg_load_calibration(app);
f_sg_reg_update(app)

end