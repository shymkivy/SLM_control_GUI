clear;
close all;

%%
fnames = {'zernike_scan_data_11_21_21_14h_59m.mat';...
          'zernike_scan_data_11_21_21_15h_40m.mat';...
          'zernike_scan_data_11_21_21_17h_12m.mat';...
          'zernike_scan_data_11_21_21_18h_7m.mat';...
          'zernike_scan_data_11_21_21_19h_10m.mat'};
      
fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\11_21_21\';


z_depths = [-100; 100; 0; 50; -50];
all_corr = cell(numel(fnames),1);
for n_fil = 1:numel(fnames)
    data = load([fpath fnames{n_fil}]);
    all_corr{n_fil} = cat(1,data.AO_correction{:});
end


all_all_corr = cat(1,all_corr{:});
unique_modes = unique(all_all_corr(:,1));


all_w = nan(numel(unique_modes),numel(fnames));
for n_mod = 1:numel(unique_modes)
    for n_fil = 1:numel(fnames)
        idx1 = all_corr{n_fil}(:,1) == unique_modes(n_mod);
        if sum(idx1)
            all_w(n_mod, n_fil) = sum(all_corr{n_fil}(idx1,2));
        end
    end
end

[z_depths_sort, sort_idx] = sort(z_depths);
all_w_sort = all_w(:,sort_idx);

col1 = jet(6);
figure; hold on;
legend_all = cell(numel(unique_modes),1);
for n_mod = 1:numel(unique_modes)
    plot(z_depths_sort, all_w_sort(n_mod,:), 'o-', 'color', col1(n_mod,:));
    legend_all{n_mod} = ['mode ' num2str(unique_modes(n_mod))];
end

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

