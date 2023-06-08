function AO_correction = f_sg_AO_do_zernike_fit(AO_data, modes_to_fit, params)

use_z_labels = 0;

num_col_divider = 6;

ao_corr_all = cat(1,AO_data.AO_correction);

max_modes = max(ao_corr_all(:,1));
max_mode_use = min([max(modes_to_fit), max_modes]);

modes_to_fit2 = 1:max_mode_use;

min_modes = min(ao_corr_all(:,1));

z_all = [AO_data.Z]';
num_z = numel(z_all);

maxZn = ceil((-1 + sqrt(1 + 4*max_modes*2))/2)-1;
zernike_nm_all = f_sg_get_zernike_mode_nm(0:maxZn);

corr_all = zeros(num_z, max_mode_use);
for n_corr = 1:num_z
    corr_all2 = zeros(max_mode_use,1);
    temp_corr = AO_data(n_corr).AO_correction;
    for n_it = 1:size(temp_corr,1)
        n_mode = temp_corr(n_it,1);
        if sum(n_mode == modes_to_fit2)
            corr_all2(n_mode) = corr_all2(n_mode) + temp_corr(n_it,2);
        end
    end
    corr_all(n_corr,:) = corr_all2;
end

if params.ignore_sherical
    idx_sph = zernike_nm_all(:,2) == 0;
    corr_all(:,idx_sph) = 0;
end

%colors1 = parula(max_mode_use-min_modes+1);
%colors1 = hsv(max_modes-min_modes+1);
colors1 = jet(max_modes-min_modes+1);

[~, sort_idx] = sort(z_all);
z_alls = z_all(sort_idx);
corr_alls = corr_all(sort_idx, :);

if params.constrain_z0
    corr_alls(z_alls==0,:) = 0;
end

if params.plot_extra
    figure; hold on
    leg_all = cell(max_mode_use,1);
    has_data = false(max_mode_use,1);
    for n_mode = 1:max_mode_use
        has_vals = corr_alls(:,n_mode) ~= 0;
        if sum(has_vals)
            leg_all{n_mode} = num2str(n_mode);
            has_data(n_mode) = 1;
            plot(z_alls(has_vals), corr_alls(has_vals,n_mode), 'o-', 'color', colors1(n_mode+1-min_modes,:));
        end

    end
    l1 = legend(leg_all(has_data));
    l1.NumColumns = ceil(sum(has_data)/10);
end

%%

z_fit = min(z_all):max(z_all);

w_fit1 = cell(numel(modes_to_fit2),1);
fit_fx = cell(numel(modes_to_fit2),1);
leg_all = cell(max_mode_use,1);
has_data = false(max_mode_use,1);
pl = cell(max_mode_use,1);
pl2 = cell(max_mode_use,1);

if params.plot_corr
    f1 = figure; hold on;
end
if params.plot_extra
    f2 = figure; hold on;
end
for n_mode = 1:numel(modes_to_fit2)
    mode = modes_to_fit2(n_mode);
    temp_data = corr_alls(:, mode);
    if params.ignore_zeros
        do_fit = or(z_alls == 0, temp_data ~=0);
    else
        do_fit = true(numel(z_alls),1);
    end
    if sum(temp_data ~=0)>1
        if use_z_labels
            leg_all{n_mode} = ['Z^{' num2str(zernike_nm_all(n_mode,2)) '}_{' num2str(zernike_nm_all(n_mode,1)) '}'];
        else
            leg_all{n_mode} = num2str(n_mode-1);
        end
        has_data(n_mode) = 1;
        [yf, w_fit11, fit_eq] = f_sg_do_fit(z_alls(do_fit), corr_alls(do_fit, mode), params);
        
        y_fit = yf(z_fit);
        w_fit1{n_mode} = w_fit11;
        fit_fx{n_mode} = yf;
        
        if params.plot_corr
            figure(f1)
            pl{n_mode} = plot(z_fit, y_fit, 'color', colors1(n_mode+1-min_modes,:), 'linewidth', 2);
            plot(z_alls(do_fit), corr_alls(do_fit, mode), '.', 'color', colors1(mode+1-min_modes,:), 'markersize', 20);
            plot(z_alls(do_fit), corr_alls(do_fit, mode), 'ko', 'linewidth', 1);
        end
        if params.plot_extra
            figure(f2);
            pl2{n_mode} = plot(z_alls(do_fit), corr_alls(do_fit, mode) - yf(z_alls(do_fit)), 'color', colors1(mode+1-min_modes,:), 'linewidth', 2);
        end
    end
end
if params.plot_corr
    figure(f1)
    l1 = legend([pl{has_data}], leg_all(has_data));
    xlabel('z defocus');
    ylabel('weight correction');
    title(sprintf('Mode correction weights, %s; sm=%.4f', params.fit_type, params.spline_smoothing_param));
    l1.NumColumns = ceil(sum(has_data)/num_col_divider);
end
if params.plot_extra
    figure(f2)
    xlabel('z')
    ylabel('fit error')
    l1 = legend([pl2{has_data}], leg_all(has_data));
    title(sprintf('Mode correction w errors, %s; sm=%.4f', params.fit_type, params.spline_smoothing_param));
    l1.NumColumns = ceil(sum(has_data)/num_col_divider);
end
%% defocus comp

if isfield(AO_data, 'defocus_comp')
    %params.fit_type = 'poly2';
    z_x = [AO_data.Z];
    idx_z_cut = abs(z_x) > params.z_defocus_correct_thresh;
    
    z_y = [AO_data.defocus_comp];
    z_y2 = z_y;
    z_y2(~idx_z_cut) = 0;
    
    yfz = f_sg_do_fit(z_x', z_y2', params);
    
    figure; hold on;
    plot(z_x, z_y, 'o');
    plot(z_x, z_y2, 'o');
    plot(z_fit,yfz(z_fit));
    title(sprintf('Defocus compensation, %s; sm=%.4f', params.fit_type, params.spline_smoothing_param));
    xlabel('z');
    ylabel('z comp');
    legend('orig', 'cut', 'fit')
else
    yfz = 0;
end

%%
AO_correction.fit_weights = [modes_to_fit2(has_data)', cat(1,w_fit1{:})];
AO_correction.AO_data = AO_data;
AO_correction.fit_eq = fit_eq;
AO_correction.fit_fx = fit_fx;
AO_correction.fit_defocus_comp = yfz;

end