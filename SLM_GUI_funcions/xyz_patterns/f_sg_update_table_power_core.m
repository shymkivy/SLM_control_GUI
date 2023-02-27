function [tab_data, powers_all] = f_sg_update_table_power_core(reg1, tab_data)

coord.xyzp = [tab_data.X, tab_data.Y, tab_data.Z];
coord.weight = tab_data.W_comp;

coord_zero = coord;
coord_zero.xyzp = [0 0 0];

[holo_phase, coord_corr] = f_sg_xyz_gen_holo(coord, reg1);

SLM_phase = angle(sum(exp(1i*(holo_phase)).*reshape(coord.weight,[1 1 numel(coord_corr.weight)]),3));

data_w_zero = f_sg_simulate_weights(reg1, zeros(size(SLM_phase)), coord_zero);
data_w = f_sg_simulate_weights(reg1, SLM_phase, coord_corr);

power_sim = data_w.pt_mags/data_w_zero.pt_mags;

power_corr = f_sg_apply_xy_power_corr(reg1.pw_corr_data, coord.xyzp(:,1:2));

tab_data.Power = power_sim.*power_corr;

powers_all = tab_data.Power;

end