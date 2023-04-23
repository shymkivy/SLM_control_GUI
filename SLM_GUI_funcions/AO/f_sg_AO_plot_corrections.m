function f_sg_AO_plot_corrections(app)

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

ao_data = reg1.AO_wf.AO_data;

AO_correction_all = cat(1,ao_data.AO_correction);

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

w_fit1 = zeros(numel(modes_to_fit),1);
w_fit2 = zeros(numel(modes_to_fit),1);
leg_all = cell(max_modes,1);
pl = cell(max_modes,1);
has_data = false(max_modes,1);
figure; hold on;
for n_mode = 1:numel(modes_to_fit)
    mode = modes_to_fit(n_mode);
    temp_data = corr_alls(:,mode);
    do_fit = or(z_alls == 0, temp_data ~=0);
    if sum(do_fit)>1
        has_data(mode) = 1;
        leg_all{mode} = num2str(mode);
        if app.constrainz0CheckBox.Value
            w_fit11 = z_alls(do_fit)\corr_alls(do_fit,mode);
            w_fit21 = 0;
            y_fit = z_fit*w_fit11;
        else
            yf = fit(z_alls(do_fit), corr_alls(do_fit,mode), 'poly1');
            y_fit = yf(z_fit);
            w_fit11 = yf.p1;
            w_fit21 = yf.p2;
        end
        w_fit1(mode) = w_fit11;
        w_fit2(mode) = w_fit21;
        
        plot(z_alls(do_fit), corr_alls(do_fit, mode), 'o', 'color', colors1(mode,:));
        pl{mode} = plot(z_fit, y_fit, 'color', colors1(mode,:));
    end
end
xlabel('z')
ylabel('weight')
title(['Mode ' num2str(modes_to_fit)])
legend([pl{has_data}], leg_all(has_data))

if app.SavefiletagEditField.Value
    reg1.AO_wf.fit_weights = [modes_to_fit', w_fit1(modes_to_fit), w_fit2(modes_to_fit)];

    z_weight_params = ao_data(1).ao_params.region_params;
    params = struct;
    params.phase_diameter = reg1.phase_diameter;
    params.AO_iteration = 1;
    params.AO_correction = [];
    params.SLMm = reg1.SLMm;
    params.SLMn = reg1.SLMn;
    if isfield(z_weight_params, 'phase_diameter')
        params.phase_diameter = z_weight_params.phase_diameter;
    elseif isfield(z_weight_params, 'beam_diameter')
        params.phase_diameter = z_weight_params.beam_diameter;
    elseif isfield(z_weight_params, 'beam_width')
        params.phase_diameter = z_weight_params.beam_width;
    end

    [reg1.AO_wf.wf_out_fit, reg1.AO_wf.wf_out_const] = f_sg_AO_compute_wf_core(reg1.AO_wf.fit_weights, params);
    
    reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
    app.region_obj_params(reg_params_idx).AO_wf = reg1.AO_wf;
    disp('saved fit')
end
end