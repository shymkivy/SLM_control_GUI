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

fname_lut = 'photodiode_lut_1064_slm5221_fianium_64r_10_10_21_20h_36m.mat';

save_tag = 'photodiode_lut_1064_slm5221_10_10_21_left_half';
          
addpath([pwd '\calibration_functions']);
%addpath([pwd '/calibration_functions']);

%%
params.two_photon = 0; % is intensity 2p? since 2pFl ~ I^2, will take sqrt
%params.smooth_win = 20;
params.order_use = 1;

params.manual_peak_selection = 0;
params.plot_stuff = 0;

sm_spline_global = 0.5; % modify for different level of smoothing
sm_spline_reg = 0.005; % modify for different level of smoothing
%%
num_files = 1;

data_load = load([path1 '/' fname_lut]);
region_gray_all = data_load.region_gray;
intens_all = data_load.AI_intensity;
num_regions = data_load.ops.NumRegions;
num_pix = data_load.ops.NumGray;
lut_source_all = data_load.ops.lut_fname;
regions_run = unique(region_gray_all(:,1));
num_regions_run = numel(regions_run);

gray1 = ((1:num_pix)-1)';

regions_idx = zeros(num_regions,1);
regions_idx(regions_run+1) = 1;

regions_all = (1:num_regions)-1;
regions_all_3d = reshape(regions_all, [sqrt(num_regions), sqrt(num_regions)])';

regions_idx_3d = zeros(size(regions_all_3d));
for n_reg = 1:num_regions_run
    regions_idx_3d(regions_all_3d==regions_run(n_reg)) = 1;
end
SLMrm = max(sum(regions_idx_3d,1));
SLMrn = max(sum(regions_idx_3d,2));

%% extract data and estimate approximate peak locations
lut_all = zeros(num_regions_run, num_pix);
for n_reg = 1:num_regions_run
    reg1 = regions_run(n_reg);
    
    reg_idx = region_gray_all(:,1) == reg1;
    lut_all(n_reg,:) = intens_all(reg_idx);

end

%% first convert from intensity to amplitude sin(phi)
% I ~ cos^2(phi/2); Fl = I^2 (two photon)
if params.two_photon
    lut_all = lut_all.^(1/2);
end
lut_all2 = (lut_all).^(1/2);

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



%% spatial smooth
% decide whether to normalize each region before spatial filt

lut_in = permute(reshape(lut_all2, [SLMrn SLMrm num_pix]), [2 1 3]);
regions_run_3d = reshape(regions_run, [SLMrn SLMrm])';

filt_std = .5;
kern_2d = fspecial('gaussian', 3, filt_std);

lut_s_3d = zeros(size(lut_in));
ones1 = ones(size(regions_run_3d));
for n_px = 1:num_pix
    lut_s_3d(:,:,n_px) = conv2(lut_in(:,:,n_px), kern_2d, 'same')./conv2(ones1, kern_2d, 'same');   
end

lut_all_s = reshape(permute(lut_s_3d, [2 1 3]), [], num_pix);

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
subreg_px = zeros(num_regions_run, num_pix);
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
    
%     figure; hold on;
%     plot(gray1, temp_lut_n)
%     plot(gray1, temp_lut_ssn)
%     plot(px_fo, phi_fo, 'k')
%     title(sprintf('reg %d', n_reg))
%     
%     figure; hold on;
%     plot(px_fo, phi_fo_int)
%     plot(px_fo2, phi_fo_int2)
%     xlim([0 255])
%     ylim([0 255])
    
    subreg_px(n_reg,:) = px_fo2;
    subreg_mmm_idx(n_reg,:) = mmm_idx;
end

subreg_mmm_idx_3d = permute(reshape(subreg_mmm_idx, [SLMrn, SLMrm, 3]), [2 1 3]);
subreg_px_3d = permute(reshape(subreg_px, [SLMrn, SLMrm, num_pix]), [2 1 3]);
%% spatial interp?

interp_fac = 2;

[X_pre, Y_pre] = meshgrid(linspace(0,1,SLMrn), linspace(0,1,SLMrm));
[X_post, Y_post] = meshgrid(linspace(0,1,SLMrn*interp_fac-1), linspace(0,1,SLMrm*interp_fac-1));

temp_cell = cell(num_pix,1);
for n_px = 1:num_pix
    temp_cell{n_px} = interp2(X_pre,Y_pre,subreg_px_3d(:,:,n_px),X_post,Y_post,'spline');
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

    n_reg = 2;
    figure; hold on;
    plot(lut_all2(n_reg,:))
    plot(lut_all2_s(n_reg,:))

    figure; hold on;
    plot(diff(lut_all_ss(n_reg,:)))

    f_save_tif_stack2_YS(subreg_px_3d - mean(mean(subreg_px_3d,1),2), [path1, save_tag, 'lut_view.tif'])
    f_save_tif_stack2_YS(subreg_px_3d_ip - mean(mean(subreg_px_3d_ip,1),2), [path1, save_tag, 'lut_view_interp.tif'])
end

%% save full region corrections
lut_corr = struct();
lut_corr.lut_corr = full_region_px;
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


