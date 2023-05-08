function f_sg_AO_plot_corrections(app)

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

ao_data = reg1.AO_wf.AO_data;

AO_correction_all = cat(1,ao_data.AO_correction);

fit_type = app.FitmethodDropDown.Value; % 'constrain_z0' 'poly1', 'poly2'
spline_smoothing_param = app.splinesmparam01EditField.Value;

max_modes = max(AO_correction_all(:,1));
%%
z_all = ([ao_data.Z])';
num_z = numel(z_all);

corr_all = zeros(num_z, max_modes);
corr_idx = (1:max_modes)';
for n_corr = 1:num_z
    corr_all2 = zeros(max_modes,1);
    temp_corr = ao_data(n_corr).AO_correction;
    for n_it = 1:size(temp_corr,1)
        n_mode = temp_corr(n_it,1);
        corr_all2(n_mode) = corr_all2(n_mode) + temp_corr(n_it,2);
    end
    corr_all(n_corr,:) = corr_all2;
end

colors1 = jet(max_modes);
[~, sort_idx] = sort(z_all);
z_alls = z_all(sort_idx);
corr_alls = corr_all(sort_idx, :);

% figure; hold on
% leg_all = cell(max_modes,1);
% has_data = false(max_modes,1);
% for n_mode = 1:max_modes
%     has_vals = corr_alls(:,n_mode) ~= 0;
%     if sum(has_vals)
%         leg_all{n_mode} = num2str(n_mode);
%         has_data(n_mode) = 1;
%     end
%     plot(z_alls(has_vals), corr_alls(has_vals,n_mode), 'o-', 'color', colors1(n_mode,:));
% end
% legend(leg_all(has_data))

%%
if isempty(app.modestofitEditField.Value)
    modes_to_fit = 1:max_modes;
else
    modes_to_fit = f_str_to_array(app.modestofitEditField.Value)';
end

z_fit = min(z_all):max(z_all);

num_modes = numel(modes_to_fit);

w_fit1 = cell(num_modes,1);
fit_fx = cell(num_modes,1);
leg_all = cell(num_modes,1);
pl = cell(num_modes,1);
pl2 = cell(num_modes,1);
modes_fit = zeros(num_modes,1);
has_data = false(num_modes,1);

f1 = figure; hold on;
if app.PloterrorCheckBox.Value
    f2 = figure; hold on;
end
for n_mode = 1:num_modes
    mode = modes_to_fit(n_mode);
    modes_fit(n_mode) = mode;
    temp_data = corr_alls(:,mode);
    do_fit = or(z_alls == 0, temp_data ~=0);
    if sum(do_fit)>1
        has_data(n_mode) = 1;
        leg_all{n_mode} = num2str(mode);
        if strcmpi(fit_type, 'poly1_constrain_z0')
            w_fit11 = z_alls(do_fit)\corr_alls(do_fit, mode);
            yf = @(x) w_fit11*x;
            fit_eq = 'yf(x) = p1*x';
        elseif strcmpi(fit_type, 'poly1')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'poly1');
            w_fit11 = [yf.p1 yf.p2];
            fit_eq = 'yf(x) = p1*x + p2';
        elseif strcmpi(fit_type, 'poly2')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'poly2');
            w_fit11 = [yf.p1 yf.p2 yf.p3];
            fit_eq = 'yf(x) = p1*x^2 + p2*x + p3';
        elseif strcmpi(fit_type, 'spline')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'spline');
            w_fit11 = [];
            fit_eq = 'spline';
        elseif strcmpi(fit_type, 'smoothingspline')
            yf = fit(z_alls(do_fit), corr_alls(do_fit, mode), 'smoothingspline', 'SmoothingParam', spline_smoothing_param);
            w_fit11 = [];
            fit_eq = 'smoothingspline';
        end
        y_fit = yf(z_fit);
        
        w_fit1{n_mode} = w_fit11;
        fit_fx{n_mode} = yf;
        
        figure(f1)
        pl{n_mode} = plot(z_fit, y_fit, 'color', colors1(n_mode,:), 'linewidth', 2);
        plot(z_alls(do_fit), corr_alls(do_fit, mode), '.', 'color', colors1(mode,:), 'markersize', 20);
        plot(z_alls(do_fit), corr_alls(do_fit, mode), 'ko', 'linewidth', 1);
        
        if app.PloterrorCheckBox.Value
            figure(f2)
            pl2{n_mode} = plot(z_alls(do_fit), corr_alls(do_fit, mode) - yf(z_alls(do_fit)), 'color', colors1(n_mode,:), 'linewidth', 2);
        end
    end
end
figure(f1)
xlabel('z')
ylabel('weight')
title(sprintf('Modes %s; %s fit', num2str(modes_to_fit), fit_type));
legend([pl{has_data}], leg_all(has_data))

if app.PloterrorCheckBox.Value
    figure(f2)
    xlabel('z')
    ylabel('fit error')
    legend([pl2{has_data}], leg_all(has_data))
    title(sprintf('Modes %s; %s fit', num2str(modes_to_fit), fit_type));
end
if app.save_fit_weightsCheckBox.Value
    %reg1.AO_wf.fit_weights = [modes_to_fit', w_fit1(modes_to_fit), w_fit2(modes_to_fit)];
    reg1.AO_wf.fit_weights = [modes_fit(has_data), cat(1,w_fit1{:})];
    reg1.AO_wf.fit_eq = fit_eq;
    reg1.AO_wf.fit_fx = fit_fx;
    
    maxZn = ceil((-1 + sqrt(1 + 4*max_modes*2))/2)-1;
    zernike_nm_all = f_sg_get_zernike_mode_nm(0:maxZn);
    reg1.AO_wf.all_modes = f_sg_gen_zernike_modes(reg1, zernike_nm_all);

    reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
    app.region_obj_params(reg_params_idx).AO_wf = reg1.AO_wf;
    disp('saved fit')
end
end