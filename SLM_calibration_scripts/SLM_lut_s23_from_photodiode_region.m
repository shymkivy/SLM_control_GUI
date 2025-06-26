% load traces, smooth
% compute aproximate peaks from full regions
% spatial filter raw lut (decide to normalize per region or no before)
% temporal filter lut
% fit phase per region
% maybe spatial interpolate here
% smooth the fits

clear;
close all

%%
path1 = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\lut_calibration\';
%path1 = 'C:\Users\ys2605\Desktop\stuff\data_others\dhruv\';

fname_data = '4x8_5400mW_photodiode_lut_spirit_victor_32r_2025_6_26_11h_06m.mat';
%fname_data = 'photodiode_lut_920_maitai_1r_03_20_25_18h_28m.mat';

%save_tag = 'photodiode_lut_1064_slm5221_4_7_22_right_half_corr2';
%save_tag = 'globar_cor';
save_tag = 'victor111';

addpath([pwd '\calibration_functions']);
%addpath([pwd '/calibration_functions']);

%%
params.two_photon = 0; % is intensity 2p? since 2pFl ~ I^2, will take sqrt
%params.smooth_win = 20;

% if automatic fitting is not working well, use manual to select window for the fit
params.manual_peak_selection = 1; % manually select peaks for fit
params.order_use = 1;   % zero order vs first order spots, where the photodiode was placed

params.plot_stuff = 0;

sm_spline_global = 0.5; % modify for different level of smoothing
% not enough smoothing may mess up peak selection, reduce for more
sm_spline_reg = 0.0001; %0.0001; % modify for different level of smoothing  0.005 for 8*4

pad_correction = 1;       % 1 for no padding (on right side); padding maybe good for recalibrations.

%%
data_load = load([path1 '/' fname_data]);

region_gray_all = data_load.region_gray;
intens_all = data_load.AI_intensity;

ops_lut = data_load.ops;

if isfield(ops_lut, 'sdkObj')
    SLMm = ops_lut.SLM_params_use.height;
    SLMn = ops_lut.SLM_params_use.width;
else
    SLMm = ops_lut.height;
    SLMn = ops_lut.width;
end
num_regions_SLM = ops_lut.NumRegions;
num_gray = ops_lut.NumGray;

regions_run = unique(region_gray_all(:,1));
num_regions_run = numel(regions_run);

gray1 = ((1:num_gray)-1)';

regions_idx = zeros(num_regions_SLM,1);
regions_idx(regions_run+1) = 1;

if isfield(data_load.ops, 'num_regions_m')
    regions_m = data_load.ops.num_regions_m;
else
    regions_m = sqrt(num_regions_SLM);
end

if isfield(data_load.ops, 'num_regions_m')
    regions_n = data_load.ops.num_regions_n;
else
    regions_n = sqrt(num_regions_SLM);
end

regions_all = (1:num_regions_SLM)-1;
regions_all_3d = reshape(regions_all, [regions_n, regions_m])';

regions_idx_3d = zeros(size(regions_all_3d));
for n_reg = 1:num_regions_run
    regions_idx_3d(regions_all_3d==regions_run(n_reg)) = 1;
end

regions_run_m = max(sum(regions_idx_3d,1));
regions_run_n = max(sum(regions_idx_3d,2));

%% load correction data used in this correction

lut_corr_data = [];

if isfield(data_load.ops, 'lut_correction_fname')
    if ~isempty(data_load.ops.lut_correction_fname)
        lut_corr_load = load([path1 '/'  data_load.ops.lut_correction_fname]);
        lut_corr_load = lut_corr_load.lut_corr;
        lut_corr_data2.lut_corr = lut_corr_load.lut_corr;
        SLMm = lut_corr_load.ops.height;
        SLMn = lut_corr_load.ops.width;
        
        if isfield(lut_corr_load.ops, 'slm_roi')
            slm_roi = lut_corr_load.ops.slm_roi;
        else
            if contains(data_load.ops.lut_correction_fname, 'right_half', 'IgnoreCase',true)
                slm_roi = 'right_half';
            elseif contains(data_load.ops.lut_correction_fname, 'left_half', 'IgnoreCase',true)
                slm_roi = 'left_half';
            elseif contains(data_load.ops.lut_correction_fname, 'full_slm', 'IgnoreCase',true)
                slm_roi = 'full_SLM';
            end
        end
        
        n_idx = true(SLMn, 1);
        n_px = ceil((1:SLMn)'/SLMn*regions_n);
        if strcmpi(slm_roi, 'right_half')
            n_idx(n_px <= floor(regions_n/2)) = 0;
            SLMm_corr = SLMm;
            SLMn_corr = SLMn/2;
        elseif strcmpi(slm_roi, 'left_half')
            n_idx(n_px > floor(regions_n/2)) = 0;
            SLMm_corr = SLMm;
            SLMn_corr = SLMn/2;
        else
            SLMm_corr = SLMm;
            SLMn_corr = SLMn;
        end
        lut_corr_data2(1).m_idx = true(SLMm, 1);
        lut_corr_data2(1).n_idx = n_idx;
        lut_corr_data2(1).SLMm_corr = SLMm_corr;
        lut_corr_data2(1).SLMn_corr = SLMn_corr;
        lut_corr_data2(1).SLMrm = lut_corr_load.SLMrm;
        lut_corr_data2(1).SLMrn = lut_corr_load.SLMrn;
        %lut_corr_data2(1).SLMrm = SLMrm;
        %lut_corr_data2(1).SLMrn = SLMrn;
        lut_corr_data = lut_corr_data2;
    end
end

%% extract data and estimate approximate peak locations
lut_all = zeros(num_regions_run, num_gray);
for n_reg = 1:num_regions_run
    reg1 = regions_run(n_reg);
    
    reg_idx = region_gray_all(:,1) == reg1;
    lut_all(n_reg,:) = intens_all(reg_idx);
end

%% first convert from intensity to amplitude sin(phi)
% I ~ cos^2(phi/2); Fl = I^2 (two photon)

if min(lut_all) < 0
    lut_alln = lut_all - min(lut_all);
else
    lut_alln = lut_all;
end

if params.two_photon
    lut_all_p = lut_alln.^(1/2);
else
    lut_all_p = lut_alln;
end

lut_all2 = (lut_all_p);%.^(1/2);

%% average across regions and approximate peak locations

temp_lut_all = sum(lut_all2,1)';
temp_lut_n = temp_lut_all - min(temp_lut_all);
temp_lut_n = temp_lut_n./max(temp_lut_n);

% smooth a bit
[~,~,out] = fit(gray1,temp_lut_n,'smoothingspline','SmoothingParam', sm_spline_global);
temp_lut_ns = temp_lut_n - out.residuals;

[px_fo, phi_fo, mmm_ind] = f_lut_fit_gamma2(temp_lut_ns, params);

phi_fo_int = phi_fo*255;
phi_fo_int2 = (0:255)';
px_fo2 = interp1(phi_fo_int, px_fo, phi_fo_int2);

txt_offset = [.05 -.05 .05];
figure; hold on; axis tight;
plot(gray1, temp_lut_n);
plot(gray1, temp_lut_ns);
plot(px_fo, phi_fo, 'k', 'LineWidth', 2);
plot(gray1(mmm_ind(1)), temp_lut_n(mmm_ind(1)), 'ro'); text(gray1(mmm_ind(1))-2,temp_lut_n(mmm_ind(1))+txt_offset(1),'0 pi');
plot(gray1(mmm_ind(2)), temp_lut_n(mmm_ind(2)), 'ro'); text(gray1(mmm_ind(2))-2,temp_lut_n(mmm_ind(2))+txt_offset(2),'1 pi');
plot(gray1(mmm_ind(3)), temp_lut_n(mmm_ind(3)), 'ro'); text(gray1(mmm_ind(3))-2,temp_lut_n(mmm_ind(3))+txt_offset(3),'2 pi');
xlabel('pixel val SLM');
ylabel('image intensity');
legend('Average E', 'Smooth E', 'phase', 'Location', 'northwest');
title(sprintf('Global gamma cal, 2p corr=%d', params.two_photon));

full_region_px = px_fo2;
full_region_mmm_idx = mmm_ind;

% add correction from past
if ~isempty(lut_corr_data)
    full_corr = squeeze(mean(mean(lut_corr_data.lut_corr,1),2));
    full_region_px_corr = zeros(size(full_region_px));
    for n_gray = 1:num_gray
        full_region_px_corr(n_gray) = full_corr(round(full_region_px(n_gray)));
    end
    full_region_mmm_idx_corr = full_corr(mmm_ind);
else
    full_region_px_corr = full_region_px;
    full_region_mmm_idx_corr = mmm_ind;
end
%% spatial smooth
% decide whether to normalize each region before spatial filt

if num_regions_SLM > 1
    lut_in = permute(reshape(lut_all2, [regions_run_n, regions_run_m, num_gray]), [2 1 3]);
    regions_run_3d = reshape(regions_run, [regions_run_n, regions_run_m])';
    
    filt_std = 1; % .5; for 8 * 4
    kern_2d = fspecial('gaussian', 3, filt_std);
    
    lut_s_3d = zeros(size(lut_in));
    ones1 = ones(size(regions_run_3d));
    for n_px = 1:num_gray
        lut_s_3d(:,:,n_px) = conv2(lut_in(:,:,n_px), kern_2d, 'same')./conv2(ones1, kern_2d, 'same');   
    end
    
    lut_all_s = reshape(permute(lut_s_3d, [2 1 3]), [], num_gray);
end
%% temporal smooth
% can do global calibration here per region
if num_regions_SLM > 1
    lut_in = lut_all_s;
    lut_all_ss = zeros(size(lut_in));
    for n_reg = 1:num_regions_run
        temp_lut = lut_in(n_reg,:)';
        [~,~,out] = fit(gray1,temp_lut,'smoothingspline','SmoothingParam', sm_spline_reg);
        lut_all_ss(n_reg,:) = temp_lut - out.residuals;
    end
end

%% for each region find lut now
if num_regions_SLM > 1
    subreg_px = zeros(num_regions_run, num_gray);
    subreg_mmm_idx = zeros(num_regions_run,3);
    subreg_mmm_idx_corr = zeros(num_regions_run,3);
    %params.plot_stuff = 0;
    %params.smooth_win = 0;
    for n_reg = 1:num_regions_run
        temp_lut = lut_all2(n_reg,:)';
        temp_lut_ss = lut_all_ss(n_reg,:)';
        
        temp_lut_n = temp_lut - min(temp_lut);
        temp_lut_n = temp_lut_n./max(temp_lut_n);
        
        temp_lut_ssn = temp_lut_ss - min(temp_lut_ss);
        temp_lut_ssn = temp_lut_ssn./max(temp_lut_ssn);
        
        [px_fo, phi_fo, mmm_idx] = f_lut_fit_gamma2(temp_lut_ssn);

        px_fo = min(px_fo*pad_correction,255);
        
        phi_fo_int = phi_fo*255;
        phi_fo_int2 = (0:255)';
        px_fo2 = interp1(phi_fo_int, px_fo, phi_fo_int2);
        
        if params.plot_stuff
            figure; hold on; axis tight;
            plot(gray1, temp_lut_n)
            plot(gray1, temp_lut_ssn)
            plot(px_fo, phi_fo, 'k')
            title(sprintf('reg %d', n_reg))
        end
    %     figure; hold on;
    %     plot(px_fo, phi_fo_int)
    %     plot(px_fo2, phi_fo_int2)
    %     xlim([0 255])
    %     ylim([0 255])
        
        subreg_px(n_reg,:) = px_fo2;
        subreg_mmm_idx(n_reg,:) = mmm_idx;
        subreg_mmm_idx_corr(n_reg,:) = full_region_mmm_idx_corr;
    end
    
    subreg_mmm_idx_3d = permute(reshape(subreg_mmm_idx, [regions_run_n, regions_run_m, 3]), [2 1 3]);
    subreg_mmm_idx_3d_corr = permute(reshape(subreg_mmm_idx_corr, [regions_run_n, regions_run_m, 3]), [2 1 3]);
    subreg_px_3d = permute(reshape(subreg_px, [regions_run_n, regions_run_m, num_gray]), [2 1 3]);
end
%% here put in the previous corrections and interpolate after
if num_regions_SLM > 1
    if ~isempty(lut_corr_data)
        
        % first reshape old correction into new shape
        [SLMrm_corr, SLMrn_corr, ~] = size(lut_corr_data.lut_corr);
        
        region_idx_corr_new = f_gen_region_index_mask(SLMm, SLMn, regions_m, regions_n);
        lut_idx_new = reshape(regions_run, regions_run_n, regions_run_m)';
        lut_corr_new = zeros(regions_run_m*regions_run_n, num_gray);
        m_fac_corr = lut_corr_data.SLMm_corr/lut_corr_data.SLMrm;
        n_fac_corr = lut_corr_data.SLMn_corr/lut_corr_data.SLMrn;
        
        for n_gray = 1:num_gray
            temp_holo_corr = zeros(lut_corr_data.SLMm_corr, lut_corr_data.SLMn_corr);
            for n_m = 1:lut_corr_data.SLMm_corr
                for n_n = 1:lut_corr_data.SLMn_corr
                    temp_holo_corr(n_m, n_n) = lut_corr_data.lut_corr(ceil(n_m/m_fac_corr), ceil(n_n/n_fac_corr),n_gray);
                end
            end
            temp_holo1 = zeros(SLMm, SLMn);
            temp_holo1(lut_corr_data.m_idx, lut_corr_data.n_idx) = temp_holo_corr;
       
            for n_reg = 1:num_regions_run
                current_reg = lut_idx_new(n_reg);
                lut_corr_new(n_reg,n_gray) = mean(temp_holo1(region_idx_corr_new==current_reg));
            end
        end
        lut_corr_new_3d = reshape(lut_corr_new, regions_run_m, regions_run_n, num_gray);
        
        %f_plot_lut_corr(lut_corr_data.lut_corr);
        %f_plot_lut_corr(lut_corr_new_3d);
        
        % apply old corrections
        subreg_px_3d_corr = zeros(size(subreg_px_3d));
        for n_m = 1:regions_run_m
            for n_n = 1:regions_run_n
                for n_gray = 1:num_gray
                    gray_idx = round(subreg_px_3d(n_m, n_n, n_gray)) + 1;
                    subreg_px_3d_corr(n_m, n_n, n_gray) = lut_corr_new_3d(n_m, n_n, gray_idx);
                end
            end
        end
    else
        subreg_px_3d_corr = subreg_px_3d;
    end
end
%% spatial interp?
if num_regions_SLM > 1
    interp_fac = 2;
    
    [X_pre, Y_pre] = meshgrid(linspace(0,1,regions_run_n), linspace(0,1,regions_run_m));
    [X_post, Y_post] = meshgrid(linspace(0,1,regions_run_n*interp_fac-1), linspace(0,1,regions_run_m*interp_fac-1));
    
    temp_cell = cell(num_gray,1);
    for n_px = 1:num_gray
        temp_cell{n_px} = interp2(X_pre,Y_pre,subreg_px_3d_corr(:,:,n_px),X_post,Y_post,'spline');
    end
    subreg_px_3d_corr_ip = cat(3,temp_cell{:});
    
    temp_cell = cell(3,1);
    for n_mmm = 1:3
        temp_cell{n_mmm} = interp2(X_pre,Y_pre,subreg_mmm_idx_3d_corr(:,:,n_mmm),X_post,Y_post,'spline');
    end
    subreg_mmm_idx_3d_corr_ip = cat(3,temp_cell{:});
end
%% plots 
if num_regions_SLM > 1
    if params.plot_stuff
    
        figure;
        subplot(3,1,1); imagesc(subreg_mmm_idx_3d(:,:,1)); title('0 pi'); colorbar();
        subplot(3,1,2); imagesc(subreg_mmm_idx_3d(:,:,2)); title('1 pi'); colorbar();
        subplot(3,1,3); imagesc(subreg_mmm_idx_3d(:,:,3)); title('2 pi'); colorbar();
    
        n_reg = 2;
        figure; hold on;
        plot(lut_all2(n_reg,:))
        plot(lut_all_s(n_reg,:))
        plot(lut_all_ss(n_reg,:))
    
        figure; hold on;
        plot(diff(lut_all_ss(n_reg,:)))
        
        figure; plot(lut_all2');
        
        % plot intensity distribution
        pad1 = 5;
        peak_idx = subreg_mmm_idx(:,2);
        peak_val = mean(lut_all2(:,(peak_idx - pad1):(peak_idx+pad1)),2);
        peak_val_3d = reshape(peak_val, [regions_run_n, regions_run_m])';
        figure;
        imagesc(peak_val_3d);
        
        f_save_tif_stack2_YS(subreg_px_3d_corr - mean(mean(subreg_px_3d_corr,1),2), [path1, save_tag, 'lut_view.tif'])
        f_save_tif_stack2_YS(subreg_px_3d_corr_ip - mean(mean(subreg_px_3d_corr_ip,1),2), [path1, save_tag, 'lut_view_interp.tif'])
    end
    
    figure;
    plot(full_region_px_corr); colorbar;
    f_plot_lut_corr(subreg_px_3d_corr);
    f_plot_lut_corr(subreg_px_3d_corr_ip);
end
%% save full region corrections
% the correction file should be used together with lut used during generation
disp('the correction file needs to be used with global .LUT file used during corrections')
lut_corr = struct();
lut_corr.lut_corr = full_region_px_corr;
lut_corr.SLMrm = 1;
lut_corr.SLMrn = 1;
lut_corr.gray = gray1;
lut_corr.mmm_idx = full_region_mmm_idx_corr;
lut_corr.fname_data = fname_data;
lut_corr.fname_lut = ops_lut.SLM_params.lut_fname;
lut_corr.regions_run = regions_run;
lut_corr.ops = ops_lut;

fname_save = [path1 save_tag '_full_region_corr.mat'];
save(fname_save, 'lut_corr');

if  num_regions_SLM == 1
    % also generate new global lut file, in case only 1 region
    lut_array = f_SLM_read_lut([path1,data_load.ops.SLM_params.lut_fname]);
    
    vq = interp1(lut_array(:,1),lut_array(:,2),full_region_px_corr);
    
    lut_out = [lut_array(:,1), round(vq)];

    f_SLM_write_lut(lut_out, [path1 save_tag '.LUT']);
    disp('anohter alternative is to use the new .LUT file on its own without corrections, as a new global LUT');

end
%% save subregions corr
if num_regions_SLM > 1
    lut_corr = struct();
    lut_corr.lut_corr = subreg_px_3d_corr;
    lut_corr.SLMrm = 8;
    lut_corr.SLMrn = 8;
    lut_corr.gray = gray1;
    lut_corr.mmm_idx = subreg_mmm_idx_3d_corr;
    lut_corr.fname_lut = ops_lut.SLM_params_use.lut_fname;
    lut_corr.regions_run_list = regions_run;
    lut_corr.ops = data_load.ops;
    
    fname_save = [path1 save_tag '_sub_region_corr.mat'];
    
    save(fname_save, 'lut_corr');
    disp('')
end

%% save interp subregions corr
if num_regions_SLM > 1
    lut_corr = struct();
    lut_corr.lut_corr = subreg_px_3d_corr_ip;
    lut_corr.SLMrm = size(subreg_px_3d_corr_ip,1);
    lut_corr.SLMrn = size(subreg_px_3d_corr_ip,2);
    lut_corr.gray = gray1;
    lut_corr.mmm_idx = subreg_mmm_idx_3d_corr_ip;
    lut_corr.fname_lut = ops_lut.SLM_params_use.lut_fname;
    lut_corr.regions_run_list = regions_run;
    lut_corr.ops = data_load.ops;
    
    fname_save = [path1 save_tag '_sub_region_interp_corr.mat'];
    save(fname_save, 'lut_corr');
end

