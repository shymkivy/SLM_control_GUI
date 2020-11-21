function f_SLM_lut_update_global(app)

% update global and list
f_SLM_lut_global_load_list(app);
app.SLM_ops.global_lut_fname = app.globalLUTDropDown.Value;

% update regional if necessary
if strcmpi(app.regionalLUTDropDown.Value, 'none')
    f_SLM_lut_regional_load_list(app);
    f_SLM_BNS_update_lut(app.SLM_ops);
else
    app.regionalLUTDropDown.Value = {'None'};
    app.SLM_ops.regional_lut_fname = libpointer('string');
    f_SLM_lut_regional_load_list(app);
    disp('reinitializeing SLM');
    f_SLM_BNS_close(app.SLM_ops);
    app.ActivateSLMLamp.Color = [0.80,0.80,0.80];
    f_SLM_BNS_initialize(app.SLM_ops);
    app.ActivateSLMLamp.Color = [0.00,1.00,0.00];
end

f_SLM_lut_correctios_load_list(app);
f_SLM_reg_update(app);

end