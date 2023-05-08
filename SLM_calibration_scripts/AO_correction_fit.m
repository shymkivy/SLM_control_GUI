clear;
close all;

%%

fnames = {'zernike_scan_data_5_6_23_13h_45m_z-200.mat';...
          'zernike_scan_data_5_5_23_22h_40m_z-150.mat';...
          'zernike_scan_data_5_7_23_22h_49m_z-100.mat';...
          %'zernike_scan_data_4_22_23_20h_35m_z-100.mat';...
          'zernike_scan_data_4_23_23_18h_34m_z-50.mat';...
          'zernike_scan_data_4_23_23_21h_11m_z0.mat';...
          'zernike_scan_data_4_23_23_2h_5m_z50.mat';...
          'zernike_scan_data_4_22_23_23h_46m_z100.mat'};
      
init_ao_file = 'AO_correction_25x_maitai_4_16_23.mat';
      
fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\4_22_23\';

save_fname = 'AO_correction_25x_maitai_5_8_23';


% fnames = {'zernike_scan_data_4_16_23_22h_59m_z-50.mat';...
%           'zernike_scan_data_4_16_23_23h_45m_z50.mat'};
%       
% fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\4_16_23\';
% 
% save_fname = 'AO_correction_25x_maitai_4_16_23';


% fnames = {'zernike_scan_data_fianium_11_25_21_18h_53m';...
%           'zernike_scan_data_fianium_11_25_21_19h_31m.mat';...
%           'zernike_scan_data_fianium_11_25_21_20h_47m.mat';...
%           'zernike_scan_data_fianium_11_25_21_23h_40m.mat';...
%           %'zernike_scan_data_fianium_11_25_21_15h_6m.mat';...
%           %'zernike_scan_data_11_22_21_17h_22m.mat';...
%           'zernike_scan_data_fianium_11_25_21_22h_15m.mat'};
%       
% fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\11_25_21\';
% 
% save_fname = 'AO_correction_25x_fianium_11_21_21_test';

% % no z
% fnames = {'zernike_scan_data_11_21_21_14h_59m.mat';...
%           'zernike_scan_data_11_21_21_15h_40m.mat';...
%           'zernike_scan_data_11_21_21_17h_12m.mat';...
%           'zernike_scan_data_11_21_21_18h_7m.mat';...
%           'zernike_scan_data_11_21_21_19h_10m.mat'};
%       
% fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\11_21_21\';
% 
% save_fname = 'AO_correction_25x_maitai_11_21_21_test';


% fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\12_12_20';
% 
% fnames = {'zernike_scan_data_20x_0um_25step_12_20_20_19h_10m';...
%           'zernike_scan_data_20x_60um_25step_12_20_20_16h_53m';...
%           'zernike_scan_data_20x_-60um_25step_12_20_20_18h_27m';...
%           'zernike_scan_data_20x_120um_25step_12_20_20_16h_6m';...
%           'zernike_scan_data_20x_-120um_25step_12_20_20_17h_41m'};
% 
% save_fname = 'AO_correction_20x_maitai_12_20_20_test';

%%
modes_to_fit = 1:30;


fit_type = 'smoothingspline'; % 'poly1_constrain_z0' 'poly1', 'poly2', 'spline', 'smoothingspline'
spline_smoothing_param = 0.0001;

constrain_z0 = 0;

save_mode_data = 0;

extra_plots = 0;

%%
ao_init_corr_weights = [1 0];
if exist('init_ao_file', 'var')
    if ~isempty(init_ao_file)
        ao_init_data = load([fpath '\' init_ao_file]);
        ao_init_corr_weights = ao_init_data.AO_correction.fit_weights;
    end
end

%z_depths = [-100; 100; 0; 50; -50];

num_fnames = numel(fnames);
  
AO_data = struct;
has_mode_data = false(num_fnames,1);
mode_data_all = cell(num_fnames,1);
max_modes = 1;
for n_corr = 1:num_fnames
    data = load([fpath '\' fnames{n_corr}]);
    if isfield(data, 'ao_data')
        data = data.ao_data;
    end
    if isfield(data, 'ao_params')
        ao_params = data.ao_params;
        AO_data(n_corr).ao_params = ao_params;
        if isfield(ao_params, 'coord')
            AO_data(n_corr).Z = ao_params.coord.xyzp(3)*1e6;
            if abs(AO_data(n_corr).Z) > 500
                AO_data(n_corr).Z = AO_data(n_corr).Z/10;
            end
        else
            AO_data(n_corr).Z = ao_params.init_coord.xyzp(3);
        end
        if isfield(AO_data(n_corr).ao_params, 'mode_data_all')
            has_mode_data(n_corr) = 1;
            mode_data_all(n_corr) = AO_data(n_corr).ao_params.mode_data_all;
            if ~save_mode_data
                AO_data(n_corr).ao_params = rmfield(AO_data(n_corr).ao_params, 'mode_data_all');
            end
        end
        if isfield(AO_data(n_corr).ao_params, 'deets_pre')
            AO_data(n_corr).ao_params = rmfield(AO_data(n_corr).ao_params, 'deets_pre');
        end
        if isfield(AO_data(n_corr).ao_params, 'region_params')
            AO_data(n_corr).ao_params = rmfield(AO_data(n_corr).ao_params, 'region_params');
        end
    end
    if isfield(data, 'init_AO_correction')
        AO_init = data.init_AO_correction;
        AO_init(AO_init(:,2) == 0,:) = [];
    else
        AO_init = ao_init_corr_weights .* [1, AO_data(n_corr).Z];
    end
    correction1 = [{AO_init}; data.AO_correction];
    correction2 = cat(1,correction1{:});
    max_modes2 = max(correction2(:,1));
    correction3 = zeros(max_modes2, 2);
    has_data = false(max_modes2,1);
    for n_mode = 1:max_modes2
        idx1 = correction2(:,1) == n_mode;
        correction3(n_mode, 1) = n_mode;
        if sum(idx1)
            correction3(n_mode, 2) = sum(correction2(idx1,2));
            has_data(n_mode) = 1;
        end
    end
    max_modes = max(max_modes, max_modes2);
    AO_data(n_corr).AO_correction = correction3(has_data,:);
end

z_all = [AO_data.Z]';

%%
if extra_plots
    mode_data1 = mode_data_all{3}{1};

    mode_data2 = mode_data1([mode_data1.mode] == 4);

    uq_1 = unique([mode_data2.weight]);

    % uq_2 = uq_1(1:3);
    % 
    % figure;
    % for n_w = 1:numel(uq_2)
    %     mode_data3 = mode_data2([mode_data2.weight] == uq_2(n_w));
    %     for n_im = 1:3
    %         num_sp = (n_w-1)*3+n_im;
    %         idx = [mode_data3.num_repeat] == n_im;
    %         subplot(numel(uq_2),3,num_sp)
    %         imagesc(mode_data3(idx).im_sm2)
    %         title(['rep ' num2str(n_im)])
    %         if n_im == 1
    %             ylabel(sprintf('w=%.2f', uq_2(n_w)))
    %         end
    %     end
    % end


    uq_2 = uq_1;

    f1 = figure;
    clim1 = [0 0];
    for n_w = 1:numel(uq_2)
        mode_data3 = mode_data2([mode_data2.weight] == uq_2(n_w));
        for n_im = 1:3
            num_sp = (n_im-1)*numel(uq_2)+n_w;
            idx = [mode_data3.num_repeat] == n_im;
            subplot(3, numel(uq_2) ,num_sp)
            im1 = imagesc(mode_data3(idx).im_sm2);
            clim1(1) = min([im1.Parent.CLim(1) clim1(1)]);
            clim1(2) = max([im1.Parent.CLim(2) clim1(2)]);
            title(sprintf('w=%.2f', uq_2(n_w)))
            if n_w == 1
                ylabel(['rep ' num2str(n_im)])
            end
        end
    end
    for n_pl = 1:numel(f1.Children)
        f1.Children(n_pl).CLim = clim1;
    end

    intens_raw = zeros(numel(uq_2),3);
    intens_sm = zeros(numel(uq_2),3);
    intens_raw2 = zeros(numel(uq_2),3);
    for n_w = 1:numel(uq_2)
        mode_data3 = mode_data2([mode_data2.weight] == uq_2(n_w));
        for n_im = 1:3
            idx = [mode_data3.num_repeat] == n_im;

            intens_raw(n_w, n_im) = mode_data3(idx).intensity_raw;
            intens_sm(n_w, n_im) = mode_data3(idx).intensity_sm;

            figure;  hold on;
            imagesc(mode_data3(idx).im_sm)

            plot(mode_data3(idx).cent_mn(2), mode_data3(idx).cent_mn(1), 'ro')

        end
    end

    col1 = parula(3);
    figure; hold on;
    for n_pl = 1:3
        plot(uq_2, intens_raw(:,n_pl), 'color', col1(n_pl,:))
        plot(uq_2, intens_sm(:,n_pl), 'Linewidth', 2, 'color', col1(n_pl,:))
    end
    plot(uq_2,mean(intens_raw,2), 'r')

end

%%

ao_corr_all = cat(1,AO_data.AO_correction);

max_modes = max(ao_corr_all(:,1));
max_mode_use = min([max(modes_to_fit), max_modes]);

modes_to_fit2 = 1:max_mode_use;

min_modes = min(ao_corr_all(:,1));

corr_all = zeros(num_fnames, max_mode_use);
corr_idx = (1:max_mode_use)';
for n_corr = 1:num_fnames
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


colors1 = parula(max_mode_use-min_modes+1);
%colors1 = hsv(max_modes-min_modes+1);
%colors1 = jet(max_modes-min_modes+1);


[~, sort_idx] = sort(z_all);
z_alls = z_all(sort_idx);
corr_alls = corr_all(sort_idx, :);

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
legend(leg_all(has_data))

%%

z_fit = min(z_all):max(z_all);

w_fit1 = cell(numel(modes_to_fit2),1);
fit_fx = cell(numel(modes_to_fit2),1);
w_fit2 = zeros(numel(modes_to_fit2),1);
leg_all = cell(max_mode_use,1);
has_data = false(max_mode_use,1);
pl = cell(max_mode_use,1);
pl2 = cell(max_mode_use,1);

f1 = figure; hold on;
f2 = figure; hold on;
for n_mode = 1:numel(modes_to_fit2)
    mode = modes_to_fit2(n_mode);
    temp_data = corr_alls(:, mode);
    do_fit = or(z_alls == 0, temp_data ~=0);
    if sum(do_fit)>1
        leg_all{n_mode} = [num2str(n_mode)];
        has_data(n_mode) = 1;
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
        pl{n_mode} = plot(z_fit, y_fit, 'color', colors1(n_mode+1-min_modes,:), 'linewidth', 2);
        plot(z_alls(do_fit), corr_alls(do_fit, mode), '.', 'color', colors1(mode+1-min_modes,:), 'markersize', 20);
        plot(z_alls(do_fit), corr_alls(do_fit, mode), 'ko', 'linewidth', 1);
        
        figure(f2);
        pl2{n_mode} = plot(z_alls(do_fit), corr_alls(do_fit, mode) - yf(z_alls(do_fit)), 'color', colors1(mode+1-min_modes,:), 'linewidth', 2);
    end
end
figure(f1)
legend([pl{has_data}], leg_all(has_data))
xlabel('z defocus')
ylabel('weight correction')
title(sprintf('Mode correction weights, %s', fit_type))

figure(f2)
xlabel('z')
ylabel('fit error')
legend([pl2{has_data}], leg_all(has_data))
title(sprintf('Mode correction w errors, %s', fit_type))

AO_correction.fit_weights = [modes_to_fit2(has_data)', cat(1,w_fit1{:})];
AO_correction.AO_data = AO_data;
AO_correction.fit_eq = fit_eq;
AO_correction.fit_fx = fit_fx;

save([fpath save_fname '.mat'], 'AO_correction');
