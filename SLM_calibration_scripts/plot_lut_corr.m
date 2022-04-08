fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\lut_calibration';

lut_corr_linear = load([fpath '/photodiode_lut_1064_slm5221_4_7_22_right_half_corr2_full_region_corr']);
lut_corr_sr = load([fpath '/photodiode_lut_1064_slm5221_4_7_22_right_half_corr2_sub_region_interp_corr']); 
lut_corr_srip = load([fpath '/photodiode_lut_1064_slm5221_10_10_21_left_half_sub_region_interp_corr']);

%close all;

figure;
imagesc(lut_corr_linear.lut_corr.lut_corr)
colorbar;
title('global lut')


f_plot_lut_corr(lut_corr_sr.lut_corr);

f_plot_lut_corr(lut_corr_srip.lut_corr);







