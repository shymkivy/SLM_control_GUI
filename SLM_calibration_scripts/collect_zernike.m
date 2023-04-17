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

    
    
AO_correction = struct;
for n_corr = 1:numel(fnames)
    
   data = load([path1 '\' fnames{n_corr}]);
   
   AO_correction(n_corr).Z = data.ao_params.coord.xyzp(3)*1e5;
   AO_correction(n_corr).AO_correction = data.AO_correction;
   AO_correction(n_corr).ao_params = data.ao_params;

end

num_modes = 20;
total_corr = zeros(num_modes, numel(fnames));
labels1 = zeros(numel(fnames),1);
for n_corr = 1:numel(fnames)
    for n_corr2 = 1:numel(AO_correction(n_corr).AO_correction)
        idx1 = round(AO_correction(n_corr).AO_correction{n_corr2}(1));
        total_corr(idx1,n_corr) = total_corr(idx1,n_corr) + AO_correction(n_corr).AO_correction{n_corr2}(2);
    end
    labels1(n_corr) = AO_correction(n_corr).Z;
end

[~, plot_idx] = sort(labels1);
figure; hold on; axis tight
for n_mode = 1:num_modes
    if sum(total_corr(n_mode,:))
        plot(labels1(plot_idx), total_corr(n_mode,plot_idx)+n_mode*0.002, '-o');
    end
end


save([path1 '\all_zernike_data_12_12_20.mat'], 'AO_correction');