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
%path1 = '/Users/yuriyshymkiv/Desktop/matlab/SLM_GUI/SLM_outputs/lut_calibration/';

fname_lut = 'photodiode_lut_940_slm5221_maitai_corr2_128r_11_07_21_19h_37m.mat';

save_tag = 'photodiode_lut_940_slm5221_11_9_21_right_half_corr2';
          
addpath([pwd '\calibration_functions']);
%addpath([pwd '/calibration_functions']);

%%
params.two_photon = 0; % is intensity 2p? since 2pFl ~ I^2, will take sqrt
%params.smooth_win = 20;
params.order_use = 1;

params.manual_peak_selection = 0;
params.plot_stuff = 0;

sm_spline_global = 0.5; % modify for different level of smoothing
sm_spline_reg = 0.0001; % modify for different level of smoothing  0.005 for 8*4
%%
data_load = load([path1 '/' fname_lut]);

region_gray_all = data_load.region_gray;
intens_all = data_load.AI_intensity;

ops_lut = data_load.ops;

SLMm = ops_lut.height;
SLMn = ops_lut.width;
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

%% 

lut_corr_data = [];

if isfield(data_load.ops, 'lut_correction_fname')
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
    
    if isfield(lut_corr_load.ops, 'SLMrn')
        SLMrn = lut_corr_load.ops.SLMrn;
        SLMrm = lut_corr_load.ops.SLMrm;
    else
        if contains(data_load.ops.lut_correction_fname, 'right_half', 'IgnoreCase',true)
            SLMrn = sqrt(lut_corr_load.ops.NumRegions)/2;
            SLMrm = sqrt(lut_corr_load.ops.NumRegions);
        elseif contains(data_load.ops.lut_correction_fname, 'left_half', 'IgnoreCase',true)
            SLMrn = sqrt(lut_corr_load.ops.NumRegions)/2;
            SLMrm = sqrt(lut_corr_load.ops.NumRegions);
        elseif contains(data_load.ops.lut_correction_fname, 'full_slm', 'IgnoreCase',true)
            SLMrn = sqrt(lut_corr_load.ops.NumRegions);
            SLMrm = sqrt(lut_corr_load.ops.NumRegions);
        end
    end
    
    region_idx = f_gen_region_index_mask(SLMm, SLMn, regions_m, regions_n);
    
    n_idx = ones(SLMn, 1);
    n_px = ceil((1:SLMn)'/SLMn*regions_n);
    if strcmpi(slm_roi, 'right_half')
        n_idx(n_px <= floor(regions_n/2)) = 0;
        
    elseif strcmpi(slm_roi, 'left_half')
        n_idx(n_px > floor(regions_n/2)) = 0;
    end
    lut_corr_data2(1).m_idx = ones(SLMm, 1);
    lut_corr_data2(1).n_idx = n_idx;
    lut_corr_data2(1).SLMcorrm = lut_corr_load.SLMrm;
    lut_corr_data2(1).SLMcorrn = lut_corr_load.SLMrn;
    lut_corr_data2(1).SLMrm = SLMrm;
    lut_corr_data2(1).SLMrn = SLMrn;
    lut_corr_data = [lut_corr_data; lut_corr_data2];
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
if params.two_photon
    lut_all_p = lut_all.^(1/2);
else
    lut_all_p = lut_all;
end
lut_all2 = (lut_all_p).^(1/2);

%% average across regions and approximate peak locations

temp_lut_all = sum(lut_all2)';
temp_lut_n = temp_lut_all - min(temp_lut_all);
temp_lut_n = temp_lut_n./max(temp_lut_n);

% smooth a bit
[~,~,out] = fit(gray1,temp_lut_n,'smoothingspline','SmoothingParam', sm_spline_global);
temp_lut_ns = temp_lut_n - out.residuals;

[px_fo, phi_fo, mmm_ind] = f_lut_fit_gamma2(temp_lut_ns);

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



if isfield(data_load.ops, 'lut_correction_fname')
    full_corr = squeeze(mean(mean(lut_corr_data.lut_corr,1),2));
    full_region_px_corr = zeros(size(full_region_px));
    for n_gray = 1:num_gray
        full_region_px_corr(n_gray) = full_corr(round(full_region_px(n_gray)));
    end
else
    full_region_px_corr = full_region_px;
end
%% spatial smooth
% decide whether to normalize each region before spatial filt

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

%% temporal smooth
% can do global calibration here per region

lut_in = lut_all_s;

lut_all_ss = zeros(size(lut_in));
for n_reg = 1:num_regions_run
    temp_lut = lut_in(n_reg,:)';
    [~,~,out] = fit(gray1,temp_lut,'smoothingspline','SmoothingParam', sm_spline_reg);
    lut_all_ss(n_reg,:) = temp_lut - out.residuals;
end

%% for each region find lut now
subreg_px = zeros(num_regions_run, num_gray);
subreg_mmm_idx = zeros(num_regions_run,3);
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
    
    phi_fo_int = phi_fo*255;
    phi_fo_int2 = (0:255)';
    px_fo2 = interp1(phi_fo_int, px_fo, phi_fo_int2);
    
    figure; hold on;
    plot(gray1, temp_lut_n)
    plot(gray1, temp_lut_ssn)
    plot(px_fo, phi_fo, 'k')
    title(sprintf('reg %d', n_reg))
    
%     figure; hold on;
%     plot(px_fo, phi_fo_int)
%     plot(px_fo2, phi_fo_int2)
%     xlim([0 255])
%     ylim([0 255])
    
    subreg_px(n_reg,:) = px_fo2;
    subreg_mmm_idx(n_reg,:) = mmm_idx;
end

subreg_mmm_idx_3d = permute(reshape(subreg_mmm_idx, [regions_run_n, regions_run_m, 3]), [2 1 3]);
subreg_px_3d = permute(reshape(subreg_px, [regions_run_n, regions_run_m, num_gray]), [2 1 3]);

%% here put in the previous corrections and interpolate after

if isfield(data_load.ops, 'lut_correction_fname')
    [sizm_corr, sizn_corr, ~] = size(lut_corr_data.lut_corr);
    SLMcorrm = lut_corr_data.SLMcorrm;
    SLMcorrn = lut_corr_data.SLMcorrn;
    
    SLMrm = lut_corr_data.SLMrm;
    SLMrn = lut_corr_data.SLMrn;
    
    % transfer data from old lut shape to new lut shape
    region_idx_corr_pre = f_gen_region_index_mask(SLMm, SLMn, SLMcorrm, SLMcorrn);
    region_idx_corr_new = f_gen_region_index_mask(SLMm, SLMn, regions_m, regions_n);

    lut_idx_pre = reshape(lut_corr_load.regions_run_list, [lut_corr_data.SLMrn, lut_corr_data.SLMrm])';
    lut_idx_new = reshape(regions_run, regions_run_n, regions_run_m)';

    lut_corr = reshape(lut_corr_load.lut_corr, [], num_gray);
    lut_corr_new = zeros(regions_run_m*regions_run_n, num_gray);
    for n_gray = 1:num_gray
        temp_holo1 = zeros(SLMm, SLMn);
        for n_reg = 1:numel(lut_corr_load.regions_run_list)
            current_reg = lut_idx_pre(n_reg);
            current_lut = lut_corr(n_reg, n_gray);
            temp_holo1(region_idx_corr_pre==current_reg) = current_lut;
        end
        for n_reg = 1:num_regions_run
            current_reg = lut_idx_new(n_reg);
            lut_corr_new(n_reg,n_gray) = mean(temp_holo1(region_idx_corr_new==current_reg));
        end
    end
    lut_corr_new_3d = reshape(lut_corr_new, regions_run_m, regions_run_n, num_gray);

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
%% spatial interp?

interp_fac = 2;

[X_pre, Y_pre] = meshgrid(linspace(0,1,regions_run_n), linspace(0,1,regions_run_m));
[X_post, Y_post] = meshgrid(linspace(0,1,regions_run_n*interp_fac-1), linspace(0,1,regions_run_m*interp_fac-1));

temp_cell = cell(num_gray,1);
for n_px = 1:num_gray
    temp_cell{n_px} = interp2(X_pre,Y_pre,subreg_px_3d_corr(:,:,n_px),X_post,Y_post,'spline');
end
subreg_px_3d_ip = cat(3,temp_cell{:});

temp_cell = cell(3,1);
for n_mmm = 1:3
    temp_cell{n_mmm} = interp2(X_pre,Y_pre,subreg_mmm_idx_3d(:,:,n_mmm),X_post,Y_post,'spline');
end
subreg_mmm_idx_3d_ip = cat(3,temp_cell{:});

%% plots 
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

    f_save_tif_stack2_YS(subreg_px_3d_corr - mean(mean(subreg_px_3d_corr,1),2), [path1, save_tag, 'lut_view.tif'])
    f_save_tif_stack2_YS(subreg_px_3d_ip - mean(mean(subreg_px_3d_ip,1),2), [path1, save_tag, 'lut_view_interp.tif'])
end

%% save full region corrections
lut_corr = struct();
lut_corr.lut_corr = full_region_px_corr;
lut_corr.SLMrm = 1;
lut_corr.SLMrn = 1;
lut_corr.gray = gray1;
lut_corr.mmm_idx = full_region_mmm_idx;
lut_corr.fname_lut = fname_lut;
lut_corr.regions_run = regions_run;
lut_corr.ops = data_load.ops;

fname_save = [path1 save_tag '_full_region_corr.mat'];
save(fname_save, 'lut_corr');

%% save subregions corr
lut_corr = struct();
lut_corr.lut_corr = subreg_px_3d;
lut_corr.SLMrm = 8;
lut_corr.SLMrn = 8;
lut_corr.gray = gray1;
lut_corr.mmm_idx = subreg_mmm_idx_3d;
lut_corr.fname_lut = fname_lut;
lut_corr.regions_run_list = regions_run;
lut_corr.ops = data_load.ops;

fname_save = [path1 save_tag '_sub_region_corr.mat'];
save(fname_save, 'lut_corr');

%% save interp subregions corr
lut_corr = struct();
lut_corr.lut_corr = subreg_px_3d_ip;
lut_corr.SLMrm = size(subreg_px_3d_ip,1);
lut_corr.SLMrn = size(subreg_px_3d_ip,2);
lut_corr.gray = gray1;
lut_corr.mmm_idx = subreg_mmm_idx_3d_ip;
lut_corr.fname_lut = fname_lut;
lut_corr.regions_run_list = regions_run;
lut_corr.ops = data_load.ops;

fname_save = [path1 save_tag '_sub_region_interp_corr.mat'];
save(fname_save, 'lut_corr');


