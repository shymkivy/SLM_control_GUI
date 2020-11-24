function f_SLM_lut_update_list(app)

% update global and list
f_SLM_lut_load_list(app);
app.SLM_ops.lut_fname = app.LUTDropDown.Value;

% update regional if necessary
f_SLM_BNS_update_lut(app.SLM_ops);

f_SLM_lut_correctios_load_list(app);
f_SLM_reg_update(app);

end