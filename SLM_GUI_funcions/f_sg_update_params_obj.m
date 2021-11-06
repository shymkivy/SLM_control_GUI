function f_sg_update_params_obj(app)

app.FOVsizeumEditField.Value = app.SLM_ops.objectives(strcmpi({app.SLM_ops.objectives.obj_name}, app.ObjectiveDropDown.Value)).FOV_size;
f_sg_reg_update(app);

end