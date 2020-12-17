% drag file into variables
data_dir = 'E:\data\SLM\lut_calibration';

fname = 'photodiode_lut_940_64r_11_10_20_15h_32m.mat';

load([data_dir '\' fname])

%% plot lut
all_regions = unique(region_gray(:,1))';

figure; hold on;

for n_reg = all_regions
    reg_idx = region_gray(:,1) == n_reg;
    plot(AI_intensity(reg_idx))
end
title(sprintf('%d regions', numel(all_regions)))


%% create raw 

new_dir1 = [data_dir '\' fname(1:end-4)];
% dump the AI measurements to a csv file
if ~exist(new_dir1, 'dir')
    mkdir(new_dir1);
end
for n_reg = all_regions
    reg_idx = region_gray(:,1) == n_reg;
    filename = ['Raw' num2str(n_reg) '.csv'];
    csvwrite([new_dir1 '\' filename], [region_gray(reg_idx,2), AI_intensity(reg_idx)]);  
end