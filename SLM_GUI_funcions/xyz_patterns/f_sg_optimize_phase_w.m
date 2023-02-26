function w_out = f_sg_optimize_phase_w(app, holo_phase, coord, I_target_in, fix_idx)

alpha_start = 1;
alpha_decrease_factor = .5;
alpha_iter_lag = 2;
alpha_update_err_thesh = 0;

error_final_thresh = 1e-5;
noise_frac = 0.01;

max_iter = 50;

plot_stuff = 0;

w0 = coord.weight;
num_w = numel(w0);

if ~exist('fix_idx', 'var')
    fix_idx = false(num_w,1);
end

num_w_mod = sum(~fix_idx);

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

coord_zero.xyzp = [0 0 0];
coord_zero.weight = 0;
data_w_zero = f_sg_simulate_weights(reg1, zeros(reg1.SLMm, reg1.SLMn), coord_zero);

SLM_phase0 = angle(sum(exp(1i*(holo_phase)).*reshape(w0,[1 1 num_w]),3));
data_w0 = f_sg_simulate_weights(reg1, SLM_phase0, coord);

I_target0 = I_target_in/sum(I_target_in)*sum(data_w0.pt_mags(~fix_idx));
err0 = mean(abs(I_target0 - data_w0.pt_mags(~fix_idx)));

w_mod = w0;
data_w = data_w0;
alpha1 = alpha_start;
alpha_iter = 0;
n_it = 1;
I_target = I_target0;

err_all = [err0; zeros(max_iter,1)];
alpha_all = [alpha_start; zeros(max_iter,1)];
while and(n_it <= max_iter, num_w_mod*err_all(n_it) > error_final_thresh)
    delta = data_w.pt_mags(~fix_idx) - I_target;
    w_mod(~fix_idx) = w_mod(~fix_idx) - alpha1*delta.*(1 + noise_frac*randn(num_w_mod,1));

    SLM_phase = angle(sum(exp(1i*(holo_phase)).*reshape(w_mod,[1 1 num_w]),3));
    data_w = f_sg_simulate_weights(reg1, SLM_phase, coord);
    I_target = I_target_in/sum(I_target_in)*sum(data_w.pt_mags(~fix_idx));

    err_all(n_it+1) = mean(abs(I_target - data_w.pt_mags(~fix_idx)));
    alpha_all(n_it+1) = alpha1;
    alpha_iter = alpha_iter + 1;
    
    if and((err_all(n_it) - err_all(n_it+1)) < alpha_update_err_thesh, alpha_iter  >= alpha_iter_lag)
        alpha1 = alpha1 * alpha_decrease_factor;
        alpha_iter = 0;
    end
    n_it = n_it + 1;
end
num_iter = n_it - 1;

err_all = err_all(1:num_iter+1);
alpha_all = alpha_all(1:num_iter+1);

w_out.w_final = w_mod;
w_out.I_final_norm = I_target;
w_out.I_final = data_w.pt_mags/data_w_zero.pt_mags;
w_out.error = err_all;
w_out.num_iter = num_iter;
w_out.data_w = data_w;

if plot_stuff
    figure; 
    subplot(2,1,1);
    plot(0:num_iter , err_all);
    xlabel('iterations');
    ylabel('mean abs error');
    title(sprintf('Absolute error, noise frac = %.2f', noise_frac));
    subplot(2,1,2);
    plot(0:num_iter , alpha_all);
    title(sprintf('Alpha value'));
    xlabel('iterations');

    figure; hold on;
    plot(I_target, 'o-', 'linewidth', 2)
    plot(data_w.pt_mags, 'o--', 'linewidth', 2)
    plot(data_w0.pt_mags, 'o--', 'linewidth', 2)
    legend('target', 'data w', 'data wo');
    title('Intensity profile before and after');
end

end