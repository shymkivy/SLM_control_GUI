function f_sg_pw_correct_weights_across_pat(app)

reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
reg_params = app.region_obj_params(reg_params_idx);

plot_stuff = 0;
corr_out = f_sg_compute_pw_corr(app, reg_params, plot_stuff);

   
tab_data = app.UIImagePhaseTable.Data;

pat_all = unique(tab_data.Pattern);

for n_pat = 1:numel(pat_all)


end