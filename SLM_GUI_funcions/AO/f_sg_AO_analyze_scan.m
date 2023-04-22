function [AO_correction_new, ao_temp, intensity_change] = f_sg_AO_analyze_scan(frames2, grad_scan_seq, ao_params, ao_temp)

reg_factor = 0.02;

n_it = ao_temp.n_it;
num_scans = numel(grad_scan_seq);

% can optimize most problematic mode here
intensity = zeros(num_scans, 1);
for n_scan = 1:num_scans
    deets1 = f_get_PFS_deets_fast(frames2(:,:,n_scan), [ao_params.sigma_pixels, ao_params.sigma_pixels]);
    if ao_params.intensity_use_peak
        intensity(n_scan) = deets1.intensity_peak;
    else
        intensity(n_scan) = deets1.intensity_mean_sm;
    end
end

mode_weight_int = [cat(1, grad_scan_seq{:}), intensity];
modes2 = unique(mode_weight_int(:,1));
num_modes_all = size(ao_temp.zernike_nm_all ,1);
x_modes_all = 1:num_modes_all;

if 1
    d_w = zeros(num_modes_all,1);
    d_i = zeros(num_modes_all,1);
    
    x_fit = min(mode_weight_int(:,2)):(ao_temp.W_step/100):max(mode_weight_int(:,2));

    for n_mode = 1:numel(modes2)
        idx1 = mode_weight_int(:,1) == modes2(n_mode);

        x0 = mode_weight_int(idx1,2);
        y0 = mode_weight_int(idx1,3);

        if 1
            yf = fit(x0 ,y0, 'smoothingspline','SmoothingParam', 0.9);
        else
            yf = fit(x0 ,y0, 'gauss1');
        end
        
        yf_fit = yf(x_fit);
        yf_reg = yf_fit.*(abs(x_fit)* -reg_factor+1)';
        
        [~, idx2] = max(yf_reg);
        peak_loc = x_fit(idx2);

        figure; hold on;
        plot(x0, y0, 'o')
        plot(x_fit, yf_fit, '-')
        plot(x_fit, yf_reg, '--')
        plot(peak_loc, yf_reg(idx2), 'ro')
        title(sprintf('iter %d; mode %d; wstep=%.2f; di=%.2f', n_it, modes2(n_mode), peak_loc, yf(peak_loc) - yf(0)))

        d_w(modes2(n_mode)) = peak_loc;
        d_i(modes2(n_mode)) = yf(peak_loc) - yf(0);
    end
    
    if sum(d_w)
        w_step = d_w .* d_i/sum(d_i);
    else
        w_step = d_w;
    end
    
    intensity_change = sum(d_i .* d_i/sum(d_i));
else
    [~, sort_idx] = sort(mode_weight_int(:,2));
    mode_weight_int2 = mode_weight_int(sort_idx,:);

    [~, sort_idx2] = sort(mode_weight_int2(:,1));
    mode_weight_int3 = mode_weight_int2(sort_idx2,:);

    mode_weight_int4 = squeeze(mean(reshape(mode_weight_int3, ao_params.scans_per_mode, [], 3),1));
    mode_weight_int5 = reshape(mode_weight_int4, num_weights, [], 3);

    intens2 = mode_weight_int5(:,:,3);

    d_w = ao_params.W_step;
    d_i = ((intens2(end,:) - intens2(1,:))/mean(intens2(:)))';

    grad2 = d_i/d_w;

    w_step2 = grad2*d_w*step_size;
    w_step(modes2) = w_step2;
end

ao_temp.step_size_all(n_it) = sum(abs(w_step));
ao_temp.w_step_all(n_it, :) = w_step;

ao_temp.step_size_all(~ao_temp.good_correction) = 0;
ao_temp.w_step_all(~ao_temp.good_correction, :) = 0;

w_step_all_cum = cumsum(ao_temp.w_step_all,1);
corr_all_weights_ma = zeros(n_it, num_modes_all);
for n_it2 = 1:n_it
    it_start = max(n_it2 - ao_params.ma_num_it , 1);
    corr_all_weights_ma(n_it2,:) = mean(ao_temp.w_step_all(it_start:n_it2,:),1);
end

AO_correction_new = [modes2, w_step(modes2)];

x_it = 1:n_it;
    
figure(ao_temp.f2)
subplot(ao_temp.sp2{1})
plot([0 x_it(ao_temp.z_all_idx)], [ao_params.init_coord.xyzp(3); ao_temp.z_all(ao_temp.z_all_idx)], 'k-o');
xlabel('iteration');
ylabel('z location (um)');

subplot(ao_temp.sp2{2}); hold off;
plot([0 x_it], [0; ao_temp.step_size_all(x_it)], 'k-o'); hold on;
plot(x_it, ao_temp.d_w_all(x_it));
xlabel('iteration');
ylabel('w mag');
legend('total step size', 'd_w', 'location', 'northwest');

color1 = gray(n_it+2);
subplot(ao_temp.sp2{3}); hold off;
plot(x_modes_all, zeros(num_modes_all, 1), '-o', 'color', color1(n_it+1,:)); hold on;
for n_it2 = 1:n_it
    plot(x_modes_all, w_step_all_cum(n_it2,:), '-o', 'color', color1(n_it+1-n_it2,:));
end
plot(x_modes_all, w_step_all_cum(n_it2,:), 'r-o');
xlabel('all modes');
ylabel('cumul corr weight');

subplot(ao_temp.sp2{4});
plot(x_modes_all, zeros(num_modes_all, 1), '-o', 'color', color1(n_it+1,:)); hold on;
for n_it2 = 1:n_it
    plot(x_modes_all, ao_temp.w_step_all(n_it2,:), '-o', 'color', color1(n_it+1-n_it2,:));
end
plot(x_modes_all, ao_temp.w_step_all(n_it2,:), 'r-o');
xlabel('all modes');
ylabel('corr step size');


subplot(ao_temp.sp2{5})
plot(x_modes_all, zeros(num_modes_all, 1), '-o', 'color', color1(n_it+1,:)); hold on;
for n_it2 = 1:n_it
    plot(x_modes_all, corr_all_weights_ma(n_it2,:), '-o', 'color', color1(n_it+1-n_it2,:));
end
plot(x_modes_all, corr_all_weights_ma(n_it2,:), 'r-o');
xlabel('all modes');
ylabel('ma step size');

end