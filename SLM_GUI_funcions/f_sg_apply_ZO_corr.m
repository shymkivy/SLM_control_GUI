function phase_out = f_sg_apply_ZO_corr(phase, reg1)

complex_exp_corr = exp(1i*(phase)) + reg1.zero_order_supp_w*exp(1i*reg1.zero_order_supp_phase);
phase_out = angle(complex_exp_corr);

end