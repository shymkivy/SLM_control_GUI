function f_SLM_LUT_update(app)

app.SLM_ops.lut_fname = app.globalLUTreactivateSLMDropDown.Value;
f_SLM_BNS_update_lut(app.SLM_ops);
f_SLM_roi_update(app);

end