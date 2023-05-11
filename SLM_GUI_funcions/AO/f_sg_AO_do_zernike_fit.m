function AO_correction = f_sg_AO_do_zernike_fit(AO_data, modes_to_fit, params)

ao_corr_all = cat(1,AO_data.AO_correction);

max_modes = max(ao_corr_all(:,1));
max_mode_use = min([max(modes_to_fit), max_modes]);

modes_to_fit2 = 1:max_mode_use;

min_modes = min(ao_corr_all(:,1));

z_all = [AO_data.Z]';
num_z = numel(z_all);

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
        leg_all{n_mode} = [num2str(n_mode)];
        has_data(n_mode) = 1;
        if strcmpi(params.fit_type, 'poly1_constrain_z0')
            w_fit11 = z_alls(do_fit)\corr_alls(do_fit, mode);
            yf = @(x) w_fit11*x;
            fit_eq = 'yf(x) = p1*x';
        elseif strcmpi(params.fit_type, 'poly1')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'poly1');
            w_fit11 = [yf.p1 yf.p2];
            fit_eq = 'yf(x) = p1*x + p2';
        elseif strcmpi(params.fit_type, 'poly2')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'poly2');
            w_fit11 = [yf.p1 yf.p2 yf.p3];
            fit_eq = 'yf(x) = p1*x^2 + p2*x + p3';
        elseif strcmpi(params.fit_type, 'spline')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'spline');
            w_fit11 = [];
            fit_eq = 'spline';
        elseif strcmpi(params.fit_type, 'smoothingspline')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'smoothingspline', 'SmoothingParam', params.spline_smoothing_param);
            w_fit11 = 0;
            fit_eq = 'smoothingspline';
        end
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
    l1.NumColumns = ceil(sum(has_data)/10);
end
if params.plot_extra
    figure(f2)
    xlabel('z')
    ylabel('fit error')
    l1 = legend([pl2{has_data}], leg_all(has_data));
    title(sprintf('Mode correction w errors, %s; sm=%.4f', params.fit_type, params.spline_smoothing_param));
    l1.NumColumns = ceil(sum(has_data)/10);
end

AO_correction.fit_weights = [modes_to_fit2(has_data)', cat(1,w_fit1{:})];
AO_correction.AO_data = AO_data;
AO_correction.fit_eq = fit_eq;
AO_correction.fit_fx = fit_fx;

end