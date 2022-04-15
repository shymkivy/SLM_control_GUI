function f_sg_pw_plot_correction(app)

reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
reg_params = app.region_obj_params(reg_params_idx);

plot_stuff = 1;
corr_out = f_sg_compute_pw_corr(app, reg_params, plot_stuff);

if isempty(corr_out)
    disp('No correction available or turned on');
end

end