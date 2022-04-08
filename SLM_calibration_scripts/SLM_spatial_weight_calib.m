addpath('C:\Users\ys2605\Desktop\stuff\AC_2p_analysis\s1_functions');

fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\spatial weight corrections\4_7_22_point_weight_measure_HC';

fname = 'Fianium_0z_1';

%%
data_Y=bigread([fpath '\' fname '.tif']);
data_CCD = csvread([fpath '\' fname '_CCD_out.csv'], 1, 0);

mov_t = data_CCD(:,3);
mean_Y = squeeze(mean(mean(data_Y,1),2));

mean_Y_st = mean_Y - min(mean_Y);
mean_Y_st = mean_Y_st/max(mean_Y_st);

data_Y_sm = f_smooth_movie(data_Y, [2 2 0]);
max_Y = double(squeeze(max(max(data_Y_sm,[],1), [],2)));
max_Y_st = max_Y - min(max_Y);
max_Y_st = max_Y_st/max(max_Y_st);


%%
volt_data = csvread([fpath '\' fname '_prairie_out.csv'], 1, 0);
stim_volt_t = volt_data(:,1)/1000;
stim_volt = volt_data(:,6);
stim_volt = stim_volt - min(stim_volt);
stim_volt = stim_volt/max(stim_volt);

sort_stim_volt = sort(stim_volt);

% set percentile
prc_volt = sum(sort_stim_volt<0.1)/numel(sort_stim_volt)*100;

prc_volt_mod = prc_volt - 0.5;

thresh_mean = prctile(mean_Y_st, prc_volt_mod);
thresh_max = prctile(max_Y_st, prc_volt_mod);

[onset_mean, offset_mean] = f_get_pulse_times(mean_Y_st, thresh_mean, 99999);
[onset_max, offset_max] = f_get_pulse_times(max_Y_st, thresh_max, 99999);

sort_vals_mean = sort(mean_Y_st);
sort_vals_max = sort(max_Y_st);

figure; plot(max_Y)
figure; plot(mean_Y)

figure; hold on;
plot(mov_t, sort_vals_mean)
plot(mov_t, sort_vals_max)
plot(stim_volt_t, sort_stim_volt)

%%
[shift, scaling_factor] = f_s1_align_traces_regress(mean_Y_st, mov_t*1000, stim_volt, [0.03 0.04]);

stim_volt_align = align_volt_by_scale_shift2(stim_volt, scaling_factor, shift);
stim_volt_al_t = ((1:numel(stim_volt_align))-1)/1000;

[onset, offset] = f_get_pulse_times(mean_Y_st, 0.03, 99999);

pulse_times_on = zeros(numel(mean_Y_st),1);
pulse_times_on(onset) = 1;
pulse_times_off = zeros(numel(mean_Y_st),1);
pulse_times_off(offset) = 1;

%%

figure; hold on;
plot(mov_t, mean_Y_st)
plot(mov_t, max_Y_st)
plot(stim_volt_al_t, stim_volt_align)
plot(mov_t, pulse_times_on)
plot(mov_t, pulse_times_off)

n_pulse = 41;
puls_time = round(mean([onset(n_pulse),offset(n_pulse)]));

figure;
imagesc(data_Y(:,:,puls_time))
title('mov raw')

figure;
imagesc(data_Y_sm(:,:,puls_time))
title('mov sm')

