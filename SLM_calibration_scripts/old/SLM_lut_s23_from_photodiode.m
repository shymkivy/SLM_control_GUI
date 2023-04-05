% this trying to do both regions together, but if split beam just do split
% by region version.

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

fname_list = {'photodiode_lut_940_slm5221_maitai_64r_10_10_21_22h_40m.mat';...
              'photodiode_lut_1064_slm5221_fianium_64r_10_10_21_20h_36m.mat'};

regions_run_list = {'right_half', 'left_half'};

save_tag = 'photodiode_lut_940_1064_slm5221_10_10_21';
          
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
num_files = numel(fname_list);

region_gray_all = cell(num_files,1);
intens_all = cell(num_files,1);
num_regions_all = zeros(num_files,1);
lut_source_all = cell(num_files,1);
pix_depth_all = zeros(num_files,1);
regions_run = cell(num_files,1);
for n_file = 1:num_files
    data_load = load([path1 fname_list{n_file}]);
    region_gray_all{n_file} = data_load.region_gray;
    intens_all{n_file} = data_load.AI_intensity;
    num_regions_all(n_file) = data_load.ops.NumRegions;
    pix_depth_all(n_file) = data_load.ops.NumGray;
    lut_source_all{n_file} = data_load.ops.lut_fname;
    if ~isfield(data_load, 'regions_run')
        if ~exist('regions_run_list')
            error('need regions_run list if not provided in ops');
        else
            regions_run{n_file} = f_lut_get_regions_run(regions_run_list{n_file}, data_load.ops.NumRegions);
        end
    end
end

region_gray_all1 = cat(1,region_gray_all{:});
intens_all1 = cat(1,intens_all{:});

regions = unique(region_gray_all1(:,1));

num_regions = max(num_regions_all);
num_pix = max(pix_depth_all);
gray1 = ((1:num_pix)-1)';

regions_idx = zeros(num_regions,1);

for n_file = 1:num_files
    regions_idx(regions_run{n_file}+1) = n_file;
end

%% extract data and estimate approximate peak locations
lut_all = zeros(num_regions, num_pix);
for n_reg = 1:num_regions
    reg1 = regions(n_reg);
    
    reg_idx = region_gray_all1(:,1) == reg1;
    lut_all(n_reg,:) = intens_all1(reg_idx);
end

%% first convert from intensity to amplitude sin(phi)
% I ~ cos^2(phi/2); Fl = I^2 (two photon)
if params.two_photon
    lut_all = lut_all.^(1/2);
end
lut_all2 = (lut_all).^(1/2);

%% average across regions and approximate peak locations
full_region_mmm_idx = zeros(num_files,3);
full_region_px = zeros(num_files,num_pix);
for n_file = 1:num_files
    temp_lut = lut_all2(regions_idx==n_file,:);
    
    temp_lut_all = sum(temp_lut)';
    
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
    title(sprintf('Full region %d; %s; gamma cal, 2p corr=%d', n_file, regions_run_list{n_file}, params.two_photon), 'interpreter', 'none');
    
    full_region_px(n_file,:) = px_fo2;
    full_region_mmm_idx(n_file,:) = mmm_ind;
end


%% spatial smooth
% decide whether to normalize each region before spatial filt

lut_in = permute(reshape(lut_all2, [8 8 256]), [2 1 3]);
regions_idx_3d = reshape(regions_idx, [8 8])';

filt_std = .5;
kern_2d = fspecial('gaussian', 3, filt_std);

lut_s_3d = zeros(size(lut_in));
for n_file = 1:num_files
    for n_px = 1:num_pix
        temp_lut = lut_in(:,:,n_px);
        temp_reg_idx = regions_idx_3d == n_file;

        ones1 = ones(size(temp_lut));

        temp_lut(~temp_reg_idx) = 0;
        ones1(~temp_reg_idx) = 0;

        temp_lut_s = conv2(temp_lut, kern_2d, 'same')./conv2(ones1, kern_2d, 'same');   

        temp_lut2 = lut_s_3d(:,:,n_px);
        temp_lut2(temp_reg_idx) = temp_lut_s(temp_reg_idx);

        lut_s_3d(:,:,n_px) = temp_lut2;
    end
end

lut_all_s = reshape(permute(lut_s_3d, [2 1 3]), [], num_pix);

%% temporal smooth
% can do global calibration here per region

lut_in = lut_all_s;

lut_all_ss = zeros(size(lut_in));
for n_reg = 1:num_regions
    reg1 = regions(n_reg);
    temp_lut = lut_in(n_reg,:)';

    [~,~,out] = fit(gray1,temp_lut,'smoothingspline','SmoothingParam', sm_spline_reg);
    lut_all_ss(n_reg,:) = temp_lut - out.residuals;
end

%%
subreg_px = zeros(num_regions, num_pix);
subreg_mmm_idx = zeros(num_regions,3);
%params.plot_stuff = 0;
%params.smooth_win = 0;
for n_reg = 1:num_regions
    reg1 = regions(n_reg);
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

subreg_mmm_idx_3d = permute(reshape(subreg_mmm_idx, [8 8, 3]), [2 1 3]);
subreg_px_3d = permute(reshape(subreg_px, [8 8, num_pix]), [2 1 3]);
%% spatial interp?

interp_fac = 2;

subreg_px_3d_ip = cell(num_files,1);
subreg_mmm_idx_3d_ip = cell(num_files,1);
for n_file = 1:num_files
    reg_idx = regions_idx_3d == n_file;
    
    SLMrm = max(sum(reg_idx,1));
    SLMrn = max(sum(reg_idx,2));
    
    [X_pre, Y_pre] = meshgrid(linspace(0,1,SLMrn), linspace(0,1,SLMrm));
    [X_post, Y_post] = meshgrid(linspace(0,1,SLMrn*interp_fac-1), linspace(0,1,SLMrm*interp_fac-1));
    
    temp_cell = cell(num_pix,1);
    
    for n_px = 1:num_pix
        
        reg_idx2 = find(reg_idx);
        
        temp_frame = subreg_px_3d(:,:,n_px);
        temp_frame2 = reshape(temp_frame(reg_idx),[SLMrm, SLMrn]);
        
        
        temp_cell{n_px} = interp2(X_pre,Y_pre,temp_frame2,X_post,Y_post,'spline');
        
    end
    
    subreg_px_3d_ip{n_file} = cat(3,temp_cell{:});
    subreg_mmm_idx_3d_ip{n_file} = ones(size(subreg_px_3d_ip{n_file},1), size(subreg_px_3d_ip{n_file},2))*n_file;
end

subreg_px_3d_ip2 = cat(2,subreg_px_3d_ip{:});
subreg_mmm_idx_3d_ip2 = cat(2,subreg_mmm_idx_3d_ip{:});

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

    f_save_tif_stack2_YS(subreg_px_3d - mean(mean(subreg_px_3d,1),2), [path1, save_tag, 'lut_view.tif'])
    f_save_tif_stack2_YS(subreg_px_3d_ip2 - mean(mean(subreg_px_3d_ip2,1),2), [path1, save_tag, 'lut_view_interp.tif'])

end

%% save full region corrections
lut_corr = struct();
lut_corr.lut_corr = reshape(full_region_px, [1 2 num_pix]);
lut_corr.SLMrm = 1;
lut_corr.SLMrn = 2;
lut_corr.gray = gray1;
lut_corr.mmm_idx = reshape(full_region_mmm_idx, [1 2 3]);
lut_corr.fname_list = fname_list;
lut_corr.regions_run_list = regions_run_list;

fname_save = [path1 save_tag 'full_region_corr.mat'];
save(fname_save, 'lut_corr');

%% save subregions corr
lut_corr = struct();
lut_corr.lut_corr = subreg_px_3d;
lut_corr.SLMrm = 8;
lut_corr.SLMrn = 8;
lut_corr.gray = gray1;
lut_corr.mmm_idx = subreg_mmm_idx_3d;
lut_corr.fname_list = fname_list;
lut_corr.regions_run_list = regions_run_list;

fname_save = [path1 save_tag 'sub_region_corr.mat'];
save(fname_save, 'lut_corr');

%% save interp subregions corr
lut_corr = struct();
lut_corr.lut_corr = subreg_px_3d_ip2;
lut_corr.SLMrm = size(subreg_px_3d_ip2,1);
lut_corr.SLMrn = size(subreg_px_3d_ip2,2);
lut_corr.gray = gray1;
lut_corr.mmm_idx = subreg_mmm_idx_3d_ip2;
lut_corr.fname_list = fname_list;
lut_corr.regions_run_list = regions_run_list;

fname_save = [path1 save_tag 'sub_region_interp_corr.mat'];
save(fname_save, 'lut_corr');


