z_depths = [100; 50; -50; -100];

fnames = {'zernike_scan_data_11_19_21_18h_43m.mat';...
          'zernike_scan_data_11_19_21_19h_52m.mat';...
          'zernike_scan_data_11_19_21_19h_34m.mat';...
          'zernike_scan_data_11_19_21_19h_5m.mat'};
      
fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\11_19_21\';

mode = 6;

w_all = zeros(numel(fnames),1);
AO_params_fit = [];
for n_fil = 1:numel(fnames)
    data = load([fpath fnames{n_fil}]);
    corr_all2 = cat(1,data.AO_correction{:});
    
    w_all(n_fil) = sum(corr_all2(corr_all2(:,1) == 6,2));
    AO_params_fit = [AO_params_fit; data.ao_params];
end


w_fit = z_depths\w_all;

z1 = -100:100;
y1 = z1*w_fit;

figure; hold on;
plot(z_depths, w_all,'o')
plot(z1, y1)
xlabel('z')
ylabel('weight')

AO_correction = struct();
AO_correction.fit_weights = [mode, w_fit];
AO_correction.fit_params = AO_params_fit;

save([fpath 'AO_correction_25x_maitai_11_21_21.mat'], 'AO_correction');

