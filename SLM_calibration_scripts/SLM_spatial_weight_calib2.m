clear;
%close all;

addpath('C:\Users\ys2605\Desktop\stuff\AC_2p_analysis\s1_functions');

fpath = 'D:\data\SLM\4_25_22_pwm';

fname = 'pwm_fianium_2pt_wrange_1_0_005_sym';

half_size_slice = 10;

%%
data_Y=bigread([fpath '\' fname '.tif']);
data_CCD = csvread([fpath '\' fname '_CCD_out.csv'], 1, 0);

[d1, d2, T] = size(data_Y);

%%
data_slm = load([fpath '\'  fname '.mat']);

data_slm = data_slm.scan_data.group_table_stim;

pat_num = data_slm(1:21,2);

weights_all = data_slm(1:21,6);


%% first get pulse times

mov_t = data_CCD(:,3);
mean_Y = squeeze(mean(mean(data_Y,1),2));

data_Y_sm = f_smooth_movie(single(data_Y), [2 2 0]);
max_Y = double(squeeze(max(max(data_Y_sm,[],1), [],2)));
max_Y_st = max_Y - min(max_Y);
max_Y_st = max_Y_st/max(max_Y_st);

f1 = figure; 
plot(max_Y_st); 
title('peak vals, click to select pulse thresh (1 click)')
[~,y_thresh] = ginput(1);
close(f1)

[onset_max, offset_max] = f_get_pulse_times(max_Y_st, y_thresh, 99999);

on_trace = zeros(numel(max_Y_st),1);
on_trace(onset_max) = 1;
off_trace = zeros(numel(max_Y_st),1);
off_trace(offset_max) = 1;

figure; hold on;
plot(max_Y_st);
plot(on_trace);
plot(off_trace);

%% new spatial location
num_puls = numel(offset_max);

puls_frames = cell(num_puls,1);
for n_puls = 1:num_puls
    puls_frames{n_puls} = mean(data_Y(:,:,onset_max(n_puls): offset_max(n_puls)),3);
end

mean_pulse_all = mean(cat(3,puls_frames{:}),3);

num_pts = 2;
mn_all = zeros(num_pts,2);
im_curr = mean_pulse_all;
for n_pt = 1:num_pts
    [~, peak_loc] = max(im_curr(:));
    [row, col] = ind2sub([d1, d2], peak_loc);
    im_curr((row - half_size_slice):(row + half_size_slice),...
            (col - half_size_slice):(col + half_size_slice)) = 0;
    mn_all(n_pt,:) = [row, col];
end

figure; hold on;
imagesc(mean_pulse_all)
for n_pt = 1:num_pts
    rectangle('Position',[mn_all(n_pt, 2) - half_size_slice,...
                          mn_all(n_pt, 1) - half_size_slice,...
                          2*half_size_slice, 2*half_size_slice]);
end
axis tight equal


%%
pts_all = cell(num_puls, num_pts);
max_all = zeros(num_puls, num_pts);
mean_all = zeros(num_puls, num_pts);
for n_puls = 1:num_puls
    for n_pt = 1:num_pts
        pts_all{n_puls, n_pt} = puls_frames{n_puls}(mn_all(n_pt, 1) - half_size_slice:...
                                    mn_all(n_pt, 1) + half_size_slice,...
                                    mn_all(n_pt, 2) - half_size_slice:...
                                    mn_all(n_pt, 2) + half_size_slice);
        max_all(n_puls, n_pt) = max(pts_all{n_puls, n_pt}(:));
        mean_all(n_puls, n_pt) = mean(pts_all{n_puls, n_pt}(:));
    end
end

figure;
for n_puls = 1:num_puls
    for n_pt = 1:num_pts
        subplot(num_pts, num_puls, ((n_pt-1)*num_puls)+n_puls);
        imagesc(pts_all{n_puls, n_pt});
        axis tight equal
        caxis([0 27000])
    end
    
end

figure; hold on;
plot(weights_all, sqrt(max_all));
plot(weights_all, sum(max_all,2))

figure; hold on;
plot(mean_all);
plot(sum(mean_all,2))

figure; plot(weights_all)
%%

mean_frame = mean(data_Y,3);
figure; imagesc(mean_frame)


win_half_size = round(mean(diff(onset_max) + diff(offset_max))); % 60
prc_base = zeros(T,1);

for n_t = 1:T
    idx_start = max(round(n_t - win_half_size), 1);
    idx_end = min(round(n_t + win_half_size), T);
    temp_trace = mean_Y(idx_start:idx_end);
    prc_base(n_t) = mode(prctile(temp_trace, 30));
end

figure; hold on;
plot(mean_Y);
plot(prc_base)

mean_Y_st = mean_Y - prc_base;
mean_Y_st = mean_Y_st/max(mean_Y_st);

figure; hold on;
plot(mean_Y_st);

data_Y_st = double(data_Y) - reshape(prc_base, [1, 1, T]);


num_on = numel(onset_max);
num_off = numel(offset_max);

if num_on ~= num_off
    error('number of onsets and offsets of puses unequal, try new thresh')
end

%%
dp1 = round(sqrt(num_on));

numX = dp1;
spacX = 25;
shiftX = 0;

numY = dp1;
spacY = 25;
shiftY = 0;

x_coords = linspace(-spacX*(numX-1)/2-shiftX, spacX*(numX-1)/2-shiftX, numX);
y_coords = linspace(-spacY*(numY-1)/2-shiftY, spacY*(numY-1)/2-shiftY, numY);

[X, Y] = meshgrid(x_coords, y_coords);

coords = [X(:), Y(:)];

%%
peak_coords = zeros(num_on,2);
means_local = zeros(num_on,1);
peak_mag = zeros(num_on,1);

for n_pl = 1:num_on
    mean_im_pulse = mean(data_Y_st(:,:,onset_max(n_pl):offset_max(n_pl)),3);
    [peak_mag2, ind_loc] = max(mean_im_pulse(:));

    [row,col] = ind2sub([d1, d2], ind_loc);
    peak_coords(n_pl,:) = [row,col];
    
    m1 = min(max(row - half_size_slice, 1), d1);
    m2 = min(max(row + half_size_slice, 1), d1);
    n1 = min(max(col - half_size_slice, 1), d2);
    n2 = min(max(col + half_size_slice, 1), d2);
    
    mean_im2 = mean_im_pulse(m1:m2, n1:n2);
    
    means_local(n_pl) = mean(mean_im2(:));
    peak_mag(n_pl) = peak_mag2;
end

means_local_st = means_local/max(means_local);
peak_mag_st = peak_mag/max(peak_mag);

means_local_st_2d = reshape(means_local_st, [dp1, dp1]);
peak_mag_st_2d = reshape(peak_mag_st, [dp1 dp1]);



% fix middle val
mid_x = find(x_coords == 0);
mid_y = find(y_coords == 0);

mean_sur = mean([means_local_st_2d(mid_y+1, mid_x),...
                    means_local_st_2d(mid_y-1, mid_x),...
                    means_local_st_2d(mid_y, mid_x+1),...
                    means_local_st_2d(mid_y, mid_x-1)]);

means_local_st_2d(mid_y, mid_x) = mean_sur;

means_local_st_2d = means_local_st_2d/max(means_local_st_2d(:));
means_local_st = means_local_st_2d(:);

peak_sur = mean([peak_mag_st_2d(mid_y+1, mid_x),...
                    peak_mag_st_2d(mid_y-1, mid_x),...
                    peak_mag_st_2d(mid_y, mid_x+1),...
                    peak_mag_st_2d(mid_y, mid_x-1)]);

peak_mag_st_2d = peak_mag_st_2d/max(peak_mag_st_2d(:));
peak_mag_st = peak_mag_st_2d(:);


figure; plot(peak_coords(:,2), peak_coords(:,1), '-o')

figure; imagesc(y_coords, x_coords, means_local_st_2d); title('means')
figure; imagesc(y_coords, x_coords, peak_mag_st_2d); title('peaks')



%%
name_tag = f_sg_get_timestamp();

weight_cal.coords_xy = coords;
weight_cal.weight_means = means_local_st;
weight_cal.weight_peaks = peak_mag_st;
weight_cal.coords_x = x_coords;
weight_cal.coords_y = y_coords;
weight_cal.weight_means_2d = means_local_st_2d;
weight_cal.weight_peaks_2d = peak_mag_st_2d;

fname_save = [fname '_' name_tag '_pw_corr.mat'];

save([fpath '\' fname_save], 'weight_cal');

%%
% %%
% volt_data = csvread([fpath '\' fname '_prairie_out.csv'], 1, 0);
% stim_volt_t = volt_data(:,1)/1000;
% stim_volt = volt_data(:,6);
% stim_volt = stim_volt - min(stim_volt);
% stim_volt = stim_volt/max(stim_volt);
% 
% sort_stim_volt = sort(stim_volt);
% 
% % set percentile
% prc_volt = sum(sort_stim_volt<0.1)/numel(sort_stim_volt)*100;
% 
% prc_volt_mod = prc_volt - 0.5;
% 
% thresh_mean = prctile(mean_Y_st, prc_volt_mod);
% thresh_max = prctile(max_Y_st, prc_volt_mod);
% 
% [onset_mean, offset_mean] = f_get_pulse_times(mean_Y_st, thresh_mean, 99999);
% [onset_max, offset_max] = f_get_pulse_times(max_Y_st, thresh_max, 99999);
% 
% sort_vals_mean = sort(mean_Y_st);
% sort_vals_max = sort(max_Y_st);
% 
% 
% figure; hold on;
% plot(mov_t, sort_vals_mean)
% plot(mov_t, sort_vals_max)
% plot(stim_volt_t, sort_stim_volt)
% 
% %%
% [shift, scaling_factor] = f_s1_align_traces_regress(mean_Y_st, mov_t*1000, stim_volt, [0.03 0.04]);
% 
% stim_volt_align = align_volt_by_scale_shift2(stim_volt, scaling_factor, shift);
% stim_volt_al_t = ((1:numel(stim_volt_align))-1)/1000;
% 
% [onset, offset] = f_get_pulse_times(mean_Y_st, 0.03, 99999);
% 
% pulse_times_on = zeros(numel(mean_Y_st),1);
% pulse_times_on(onset) = 1;
% pulse_times_off = zeros(numel(mean_Y_st),1);
% pulse_times_off(offset) = 1;
% 
% %%
% 
% figure; hold on;
% plot(mov_t, mean_Y_st)
% plot(mov_t, max_Y_st)
% plot(stim_volt_al_t, stim_volt_align)
% plot(mov_t, pulse_times_on)
% plot(mov_t, pulse_times_off)
% 
% n_pulse = 41;
% puls_time = round(mean([onset(n_pulse),offset(n_pulse)]));
% 
% figure;
% imagesc(data_Y(:,:,puls_time))
% title('mov raw')
% 
% figure;
% imagesc(data_Y_sm(:,:,puls_time))
% title('mov sm')
% 
