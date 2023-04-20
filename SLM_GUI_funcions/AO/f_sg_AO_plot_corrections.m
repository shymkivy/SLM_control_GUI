function f_sg_AO_plot_corrections(app)

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

init_AO_phase = f_sg_AO_get_z_corrections(app, reg1, app.current_SLM_coord.xyzp(:,3));

end