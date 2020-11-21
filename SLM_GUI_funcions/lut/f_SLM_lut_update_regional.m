function f_SLM_lut_update_regional(app)

f_SLM_lut_regional_load_list(app);
if strcmpi(app.regionalLUTDropDown.Value, 'none')
    app.SLM_ops.regional_lut_fname = libpointer('string');
else
    app.SLM_ops.regional_lut_fname = app.regionalLUTDropDown.Value;
end
f_SLM_lut_correctios_load_list(app);

disp('reinitializeing SLM');
f_SLM_BNS_close(app.SLM_ops);
app.ActivateSLMLamp.Color = [0.80,0.80,0.80];
f_SLM_BNS_initialize(app.SLM_ops);
app.ActivateSLMLamp.Color = [0.00,1.00,0.00];

end