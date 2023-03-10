clear; close all;


fpath = '\\BESTIA_SLM\Users\rylab_901c_slm\Desktop\Yuriy\SLM_GUI\SLM_outputs\lut_calibration';
fname = 'photodiode_zero_orderlut_940_maitai_2r_03_09_23_18h_11m.mat';
data = load([fpath '\' fname]);


reg_all = unique(data.region_gray(:,1));

figure; hold on;
for n_reg = 1:numel(reg_all)
    reg1 = reg_all(n_reg);

    reg_idx = data.region_gray(:,1) == reg1;
    
    y_fit = f_smooth_nd(data.AI_intensity(reg_idx), [4,0]);
    [~, idx_min] = min(y_fit);
    
    plot(data.region_gray(reg_idx,2), data.AI_intensity(reg_idx))
    plot(data.region_gray(reg_idx,2), y_fit);
    plot(data.region_gray(idx_min,2), y_fit(idx_min), 'ro')
    
end
ylabel('phase');
title(sprintf('Phase vs intensity, w_start=%.2f; min phase=%.2f, %.5f rad', data.ops.weight_start, data.region_gray(idx_min,2), data.region_gray(idx_min,2)/255*2*pi), 'interpreter', 'none'); % phase sel=%.2f


reg_all = unique(data.region_w(:,1));

figure; hold on;
for n_reg = 1:numel(reg_all)
    reg1 = reg_all(n_reg);

    reg_idx = data.region_w(:,1) == reg1;
    
    y_fit = f_smooth_nd(data.AI_intensity_w(reg_idx), [4,0]);
    
    [~, idx_min] = min(y_fit);
    
    plot(data.region_w(reg_idx,2), data.AI_intensity_w(reg_idx), '.-')
    plot(data.region_w(reg_idx,2), y_fit);
    plot(data.region_w(idx_min,2), y_fit(idx_min), 'ro')
end
ylabel('weight')
title(sprintf('weight vs intensity; min W = %.2f', data.region_w(idx_min,2)), 'interpreter', 'none');

