function f_sg_lut_update_list(app)

% update global and list
f_sg_lut_load_list(app);
app.SLM_ops.lut_fname = app.LUTDropDown.Value;

% update regional if necessary
f_SLM_BNS_update_lut(app.SLM_ops);

f_sg_lut_correctios_load_list(app);
f_sg_reg_update(app);

end