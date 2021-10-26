% load traces, smooth
% compute aproximate peaks from full regions
% fit lut per region
% smooth the fits

clear;
close all


%%
path1 = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\lut_calibration\';
%path1 = '/Users/yuriyshymkiv/Desktop/matlab/SLM_GUI/SLM_outputs/lut_calibration/';

fname_list = {'photodiode_lut_940_slm5221_maitai_64r_10_10_21_22h_40m.mat';...
              'photodiode_lut_1064_slm5221_fianium_64r_10_10_21_20h_36m.mat'};

regions_run_list = {'left_half', 'right_half'};
          
addpath([pwd '\calibration_functions']);
%addpath([pwd '/calibration_functions']);

%%
params.two_photon = 0; % is intensity 2p? since 2pFl ~ I^2, will take sqrt
params.smooth_win = 20;
params.order_use = 1;

params.manual_peak_selection = 0;
params.plot_stuff = 1;

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
gray1 = (1:num_pix)-1;

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


%%
temp_lut = mean(lut_all2(regions_idx==1,:));

curv_range = [2 8];
data_out = f_curv_dep_smooth(temp_lut, curv_range);


%% average across regions and approximate peak locations
min_max_min_ave = cell(num_files,1);
ps_params = params;
ps_params.plot_stuff = 1;
ps_params.smooth_win = 10;
for n_file = 1:num_files
    temp_lut = lut_all2(regions_idx==n_file,:);

    temp_lut = temp_lut - min(temp_lut,[],2);
    temp_lut = temp_lut./max(temp_lut,[],2);
    
    min_max_min_ave{n_file} = f_lut_peak_selection(mean(temp_lut), ps_params);
    title(sprintf('Region %d, order=%d , manual=%d, smooth=%d', n_file, ps_params.order_use, ps_params.manual_peak_selection, ps_params.smooth_win))
end

%%
% can do global calibration here per region

%%
lut_fits = zeros(num_regions, num_pix);
%params.plot_stuff = 0;
%params.smooth_win = 0;
for n_reg = 1:num_regions
    reg1 = regions(n_reg);
    
    [px_fo, phi_fo] = f_lut_fit_gamma([gray1', lut_all(n_reg,:)'], 1, params, min_max_min_ave{regions_idx(n_reg)});

end


%%

data_fo_rn = (data_fo_r).^(1/2);
if params.two_photon
    data_fo_rn = data_fo_rn.^(1/2);
end



%% some smoothing in 3d, any normalization should be done after any sqrt
lut_all_s = smoothdata(lut_all, 2, 'gaussian', params.smooth_win);
lut_min = min(lut_all_s,[],2);
lut_max = max(lut_all_s-lut_min,[],2);

lut_all_n = (lut_all - lut_min)./lut_max;
lut_all_sn = (lut_all_s - lut_min)./lut_max;

SLMm = round(sqrt(num_regions));
SLMn = round(sqrt(num_regions));

lut_all_3d = permute(reshape(lut_all,[SLMn SLMm 256]), [2 1 3]);
regions_idx_3d = reshape(regions_idx,[SLMn SLMm])';

lut_all_3ds = smoothdata(lut_all_3d, 3, 'gaussian', params.smooth_win);

lut_min = min(lut_all_3ds,[],3);
lut_max = max(lut_all_3ds-lut_min,[],3);

lut_all_3dn = (lut_all_3d - lut_min)./lut_max;
lut_all_3dsn = (lut_all_3ds - lut_min)./lut_max;


gauss_filt = fspecial('gaussian',3,1);

lut_all_3dsns = zeros(size(lut_all_3dsn));

for n_file = 1:num_files
    for n_pix = 1:num_pix
        temp_lut = lut_all_3dsn(:,:,n_pix);
        temp_lut(regions_idx_3d ~= n_file) = 0;      
        temp_lut_f = conv2(temp_lut, gauss_filt, 'same');
        temp_lut_f(regions_idx_3d ~= n_file) = 0;
        
        temp_frame = lut_all_3dsns(:,:,n_pix);
        temp_frame(regions_idx_3d == n_file) = temp_lut_f(regions_idx_3d == n_file);
        
        lut_all_3dsns(:,:,n_pix) = temp_frame;
    end
end

% renormalize edges after zero padded conv
lut_all_3dsnsn = lut_all_3dsns - min(lut_all_3dsns,[],3);
lut_all_3dsnsn = lut_all_3dsnsn./max(lut_all_3dsnsn,[],3);

lut_all_snsn = reshape(permute(lut_all_3dsnsn, [2 1 3]), [], 256);

% for m = 1:8
%     for n = 1:8
%         figure; hold on;
%         plot(squeeze(lut_all_3dsn(m,n,:)))
%         plot(squeeze(lut_all_3dn(m,n,:)))
%         plot(squeeze(lut_all_3dsnsn(m,n,:)))
%         title([num2str(m), num2str(n)])
%     end
% end

% 
% interp_fac = 2;
% [X,Y] = meshgrid(linspace(0,1,SLMm),linspace(0,1,SLMn));
% [X2,Y2] = meshgrid(linspace(0,1,SLMm*interp_fac),linspace(0,1,SLMn*interp_fac));


%% for each region select 0 pi 2pi

lut_fits = zeros(num_regions, num_pix);
%params.plot_stuff = 0;
params.smooth_win = 0;
for n_reg = 1:num_regions
    reg1 = regions(n_reg);
    
    [px_fo, phi_fo] = f_lut_fit_gamma([gray1', lut_all_snsn(n_reg,:)'], 1, params, min_max_min_ave{regions_idx(n_reg)});

end

m = sqrt(num_regions);
n = sqrt(num_regions);

lut_data = zeros(m, n, num_pix);

for n_m = 1:m
    for n_n = 1:n
        idx1 = (n_m-1)*n + n_n;
        reg1 = regions(idx1);
        reg_idx = region_gray_all1(:,1) == reg1;
        gray1 = region_gray_all1(reg_idx,2);
        ai_intens = intens_all1(reg_idx);

        [px_fo, phi_fo] = f_lut_fit_gamma([gray1, ai_intens], 1, params);

        x = phi_fo*255;
        v = px_fo;
        xq = (0:255)';
        vq = interp1(x, v, xq);

        lut_data(n_m,n_n,:) = vq;
        sgtitle(reg1)
    end
end

figure; imagesc(lut_data(:,:,20))

figure; plot(px_fo, phi_fo)

figure; plot(xq, vq)

figure; plot(gray1,ai_intens)

%%


f_save_tif_stack2_YS(lut_all_3dn, [path1, 'test.tif'])




