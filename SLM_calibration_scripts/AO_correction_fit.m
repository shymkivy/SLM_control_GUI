clear;
close all;

%%
% fnames = {'zernike_scan_data_fianium_11_25_21_18h_53m';...
%           'zernike_scan_data_fianium_11_25_21_19h_31m.mat';...
%           'zernike_scan_data_fianium_11_25_21_20h_47m.mat';...
%           'zernike_scan_data_fianium_11_25_21_23h_40m.mat';...
%           %'zernike_scan_data_fianium_11_25_21_15h_6m.mat';...
%           %'zernike_scan_data_11_22_21_17h_22m.mat';...
%           'zernike_scan_data_fianium_11_25_21_22h_15m.mat'};
%       
% fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\11_25_21\';

fnames = {'zernike_scan_data_11_21_21_14h_59m.mat';...
          'zernike_scan_data_11_21_21_15h_40m.mat';...
          'zernike_scan_data_11_21_21_17h_12m.mat';...
          'zernike_scan_data_11_21_21_18h_7m.mat';...
          'zernike_scan_data_11_21_21_19h_10m.mat'};
      
fpath = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs\AO_outputs\11_21_21\';

save_fname = 'AO_correction_25x_maitai_11_21_21';

%%
mode = 5;

extra_plots = 0;

%%

%z_depths = [-100; 100; 0; 50; -50];

z_depths = zeros(numel(fnames),1);
mode_data = cell(numel(fnames),1);
all_corr = cell(numel(fnames),1);
for n_fil = 1:numel(fnames)
    data = load([fpath fnames{n_fil}]);
    z_depths(n_fil) = data.ao_params.coord.xyzp(3);
    mode_data{n_fil} = data.ao_params.mode_data_all;
    all_corr{n_fil} = cat(1,data.AO_correction{:});
end

if extra_plots
    mode_data1 = mode_data{3}{1};

    mode_data2 = mode_data1([mode_data1.mode] == 4);

    uq_1 = unique([mode_data2.weight]);

    % uq_2 = uq_1(1:3);
    % 
    % figure;
    % for n_w = 1:numel(uq_2)
    %     mode_data3 = mode_data2([mode_data2.weight] == uq_2(n_w));
    %     for n_im = 1:3
    %         num_sp = (n_w-1)*3+n_im;
    %         idx = [mode_data3.num_repeat] == n_im;
    %         subplot(numel(uq_2),3,num_sp)
    %         imagesc(mode_data3(idx).im_sm2)
    %         title(['rep ' num2str(n_im)])
    %         if n_im == 1
    %             ylabel(sprintf('w=%.2f', uq_2(n_w)))
    %         end
    %     end
    % end


    uq_2 = uq_1;

    f1 = figure;
    clim1 = [0 0];
    for n_w = 1:numel(uq_2)
        mode_data3 = mode_data2([mode_data2.weight] == uq_2(n_w));
        for n_im = 1:3
            num_sp = (n_im-1)*numel(uq_2)+n_w;
            idx = [mode_data3.num_repeat] == n_im;
            subplot(3, numel(uq_2) ,num_sp)
            im1 = imagesc(mode_data3(idx).im_sm2);
            clim1(1) = min([im1.Parent.CLim(1) clim1(1)]);
            clim1(2) = max([im1.Parent.CLim(2) clim1(2)]);
            title(sprintf('w=%.2f', uq_2(n_w)))
            if n_w == 1
                ylabel(['rep ' num2str(n_im)])
            end
        end
    end
    for n_pl = 1:numel(f1.Children)
        f1.Children(n_pl).CLim = clim1;
    end

    intens_raw = zeros(numel(uq_2),3);
    intens_sm = zeros(numel(uq_2),3);
    intens_raw2 = zeros(numel(uq_2),3);
    for n_w = 1:numel(uq_2)
        mode_data3 = mode_data2([mode_data2.weight] == uq_2(n_w));
        for n_im = 1:3
            idx = [mode_data3.num_repeat] == n_im;

            intens_raw(n_w, n_im) = mode_data3(idx).intensity_raw;
            intens_sm(n_w, n_im) = mode_data3(idx).intensity_sm;

            figure;  hold on;
            imagesc(mode_data3(idx).im_sm)

            plot(mode_data3(idx).cent_mn(2), mode_data3(idx).cent_mn(1), 'ro')

        end
    end

    col1 = parula(3);
    figure; hold on;
    for n_pl = 1:3
        plot(uq_2, intens_raw(:,n_pl), 'color', col1(n_pl,:))
        plot(uq_2, intens_sm(:,n_pl), 'Linewidth', 2, 'color', col1(n_pl,:))
    end
    plot(uq_2,mean(intens_raw,2), 'r')

end

%%
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

%%

w_all = zeros(numel(fnames),1);
for n_fil = 1:numel(fnames)
    corr_all2 = all_corr{n_fil};
    w_all(n_fil) = sum(corr_all2(corr_all2(:,1) == mode,2));
end

w_fit = z_depths\w_all;

z1 = -100:100;
y1 = z1*w_fit;

figure; hold on;
plot(z_depths, w_all,'o')
plot(z1, y1)
xlabel('z')
ylabel('weight')
title(['Mode ' num2str(mode)])

AO_correction = struct();
AO_correction.fit_weights = [mode, w_fit];
AO_correction.fit_params = AO_params_fit;

%save([fpath save_fname '.mat'], 'AO_correction');