function w_out = f_sg_optimize_phase_w_bd(app, holo_phase, holo_phase_bd, coord, coord_bd, I_target_in)

alpha_start = 1;
alpha_decrease_factor = .5;
alpha_iter_lag = 1;
alpha_update_err_thesh = 0;

error_final_thresh = 1e-4;
noise_frac = 0.01;

max_iter = 50;

plot_stuff = 0;

w0 = coord.W_est;
wbd0 = coord_bd.W_est;
num_w = numel(w0);

holo_phase2 = cat(3, holo_phase, holo_phase_bd);

coord2 = coord;
coord2.xyzp = [coord.xyzp; coord_bd.xyzp];
coord2.W_est = [coord.W_est; coord_bd.W_est];

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

coord_zero.xyzp = [0 0 0];
coord_zero.W_est = 0;
data_w_zero = f_sg_simulate_intensity(reg1, zeros(reg1.SLMm, reg1.SLMn), coord_zero, app.pointsizeumEditField.Value, app.UsegaussianbeamampCheckBox.Value, app.I_estI22PCheckBox.Value);

SLM_phase0 = angle(sum(exp(1i*(holo_phase2)).*reshape([w0; wbd0],[1 1 num_w+1]),3));
data_w0 = f_sg_simulate_intensity(reg1, SLM_phase0, coord2, app.pointsizeumEditField.Value, app.UsegaussianbeamampCheckBox.Value, app.I_estI22PCheckBox.Value);

I_target0 = I_target_in;
err0 = mean(abs(I_target0 - data_w0.pt_mags(1:num_w)/data_w_zero.pt_mags));

w_mod = w0;
w_mod_bd = wbd0;
data_w = data_w0;
alpha1 = alpha_start;
alpha_iter = 0;
n_it = 1;
I_target = I_target0;

err_all = [err0; zeros(max_iter,1)];
alpha_all = [alpha_start; zeros(max_iter,1)];
tic();
if err0 > error_final_thresh
    while and(n_it <= max_iter, num_w*err_all(n_it) > error_final_thresh)
        delta = data_w.pt_mags(1:num_w) - I_target; % /data_w_zero.pt_mags
        delta2 = alpha1*delta.*(1 + noise_frac*randn(num_w,1));
        temp_w_mod = w_mod;
        temp_w_mod = temp_w_mod - delta2;
        temp_w_mod_bd = w_mod_bd;
        temp_w_mod_bd = max(temp_w_mod_bd + sum(delta2), 0);

        SLM_phase = angle(sum(exp(1i*(holo_phase2)).*reshape([temp_w_mod; temp_w_mod_bd],[1 1 num_w+1]),3));
        temp_data_w = f_sg_simulate_intensity(reg1, SLM_phase, coord2, app.pointsizeumEditField.Value, app.UsegaussianbeamampCheckBox.Value, app.I_estI22PCheckBox.Value);
        
        %I_target = I_target_in/sum(I_target_in)*sum(temp_data_w.pt_mags);
        temp_err = mean(abs(I_target - temp_data_w.pt_mags(1:num_w)));
        
        % if error decreases, update w
        if temp_err < err_all(n_it)
            err_all(n_it+1) = temp_err;
            data_w = temp_data_w;
            w_mod = temp_w_mod;
            w_mod_bd = temp_w_mod_bd;
        else
            err_all(n_it+1) = err_all(n_it);
        end
        
        err_all(n_it+1) = mean(abs(I_target - data_w.pt_mags(1:num_w))); % /data_w_zero.pt_mags
        alpha_all(n_it+1) = alpha1;
        alpha_iter = alpha_iter + 1;

        if and((err_all(n_it) - err_all(n_it+1)) < alpha_update_err_thesh, alpha_iter  >= alpha_iter_lag)
            alpha1 = alpha1 * alpha_decrease_factor;
            alpha_iter = 0;
        end
        n_it = n_it + 1;
    end
end
dur1 = toc();
num_iter = n_it - 1;
err_all = err_all(1:num_iter+1);
alpha_all = alpha_all(1:num_iter+1);

w_out.w_final = w_mod;
w_out.wbd_final = w_mod_bd;
w_out.I_final = data_w.pt_mags(1:num_w);%/data_w_zero.pt_mags;
w_out.Ibd_final = data_w.pt_mags(end);%/data_w_zero.pt_mags;
w_out.I_target = I_target;
w_out.error = err_all;
w_out.num_iter = num_iter;
w_out.data_w = data_w;

if plot_stuff
    figure; 
    subplot(2,1,1);
    plot(0:num_iter , err_all, 'o-');
    xlabel('iterations');
    ylabel('mean abs error');
    title(sprintf('Absolute error, noise frac = %.2f; duration=%.2f sec', noise_frac, dur1))
    subplot(2,1,2);
    plot(0:num_iter , alpha_all);
    title(sprintf('Alpha value'));
    xlabel('iterations');

    figure; hold on;
    plot(w_out.I_target(1:num_w), 'o-', 'linewidth', 2);
    plot(w_out.I_final(1:num_w), 'o-.', 'linewidth', 2);
    plot(data_w0.pt_mags(1:num_w), 'o--', 'linewidth', 1.5);
    legend('target', 'data w', 'data wo');
    title('Intensity profile before and after');
end

end