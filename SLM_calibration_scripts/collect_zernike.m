clear;
close all;

path1 = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\12_12_20';
fnames = {'zernike_scan_data_20x_0um_25step_12_20_20_19h_10m';...
          'zernike_scan_data_20x_60um_25step_12_20_20_16h_53m';...
          'zernike_scan_data_20x_-60um_25step_12_20_20_18h_27m';...
          'zernike_scan_data_20x_120um_25step_12_20_20_16h_6m';...
          'zernike_scan_data_20x_-120um_25step_12_20_20_17h_41m'};

% 
% path1 = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs';
% fnames = {'zernike_scan_data_4_16_23_22h_59m_z-50';...
%           'zernike_scan_data_4_16_23_23h_45m_z50'};
% 

num_fnames = numel(fnames);
    
AO_correction = struct;
for n_corr = 1:num_fnames

    data = load([path1 '\' fnames{n_corr}]);

    AO_correction(n_corr).Z = data.ao_params.coord.xyzp(3)*1e5;
    AO_correction(n_corr).AO_correction = cat(1,data.AO_correction{:});
    AO_correction(n_corr).ao_params = data.ao_params;

end

max_mode = 1;
for n_corr = 1:num_fnames
    max_mode = max(max(AO_correction(n_corr).AO_correction(:,1)), max_mode);
end

z_all = zeros(num_fnames, 1);
corr_all = zeros(num_fnames, max_mode);
corr_idx = (1:max_mode)';
for n_corr = 1:num_fnames
    z_all(n_corr) = AO_correction(n_corr).Z;
    corr_all2 = zeros(max_mode,1);
    for n_it = 1:size(AO_correction(n_corr).AO_correction,1)
        n_mode = AO_correction(n_corr).AO_correction(n_it,1);
        corr_all2(n_mode) = corr_all2(n_mode) + AO_correction(n_corr).AO_correction(n_it,2);
    end
    corr_all(n_corr,:) = corr_all2;
    AO_correction(n_corr).AO_correction2 = [corr_idx, corr_all2];
end

colors1 = jet(max_mode);
[~, idx1] = sort(z_all);

z_alls = z_all(idx1);
corr_alls = corr_all(idx1,:);


figure; hold on
leg_all = cell(max_mode,1);
has_data = false(max_mode,1);
for n_mode = 1:max_mode
    has_vals = corr_alls(:,n_mode) ~= 0;
    if sum(has_vals)
        leg_all{n_mode} = num2str(n_mode);
        has_data(n_mode) = 1;
    end
    plot(z_alls(has_vals), corr_alls(has_vals,n_mode), 'o-', 'color', colors1(n_mode,:));
end
legend(leg_all(has_data))


save([path1 '\all_zernike_data_12_12_20.mat'], 'AO_correction');