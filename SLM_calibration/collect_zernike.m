
path1 = 'C:\Users\ys2605\Desktop\stuff\SLM_microscope_GUI\SLM_calibration\AO_correction';

fnames = {'zernike_scan_data_50_15_12_11_20_16h_18m';...
        'zernike_scan_data_-50_15_12_11_20_16h_55m';...
        'zernike_scan_data_100_15_12_11_20_12h_29m';...
        'zernike_scan_data_-100_15_12_11_20_15h_34m'};

    
    
AO_correction = struct;
for n_corr = 1:numel(fnames)
    
   data = load([path1 '\' fnames{n_corr}]);
   
   AO_correction(n_corr).Z = data.ao_params.coord.xyzp(3)*1e5;
   AO_correction(n_corr).AO_correction = data.AO_correction;
   AO_correction(n_corr).ao_params = data.ao_params;

end
    
    
save([path1 '\all_zernike_data_12_11_20.mat'], 'AO_correction');