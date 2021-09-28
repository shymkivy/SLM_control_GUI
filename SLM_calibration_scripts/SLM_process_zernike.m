close all;

dir_path = 'E:\data\SLM\AO\12_1_20\';
mov_name = 'zernike_100umoff_4_3_.5-001';

save_date = '12_1_20';

Y = f_collect_prairie_tiffs3([dir_path mov_name]);

load_file_name = 'zernike_scan_data_12_1_20_17h_41m';
load([dir_path load_file_name '.mat']);

%zernike_AO_data.current_correction;
scanned_sequence = zernike_AO_data.zernike_scan_sequence;
zernike_table = zernike_AO_data.zernike_table;
[dim1, dim2, num_images] = size(Y);
scanned_sequence = [scanned_sequence, (1:num_images)'];
scanned_modes = unique(scanned_sequence(:,1));
num_scanned_modes = numel(scanned_modes);

weights1 = scanned_sequence((scanned_sequence(:,1)==scanned_modes(1)),2);
num_reps = round(numel(weights1)/numel(unique(weights1)));

%Y = Y(:,:,1:num_images);


%% mark regions
figure; imagesc(mean(Y,3)); hold on; axis equal tight;
title('how many regions to use?');
num_regions = input("how many regions to use?: ");
regions = cell(num_regions,1);
coords = cell(num_regions,1);
for n_point = 1:num_regions
    [x1, y1] = ginput(2);
    x1 = round(x1);
    y1 = round(y1);
    coords{n_point} = [x1, y1];
    rectangle('Position',[min(x1) min(y1)  abs(x1(1)-x1(2)) abs(y1(1)-y1(2))]);
    regions{n_point} = Y(y1(1):y1(2),x1(1):x1(2),:);
end
title('Regions to analyze');

%% analysis of regions
im_means = zeros(num_images,num_regions);
for n_point = 1:num_regions
    im_means(:,n_point) = squeeze(mean(mean(regions{n_point},1),2));
end

im_peak_means = zeros(num_images,num_regions);
ave_top_num = 3;
for n_point = 1:num_regions
    Y3_temp = sort(reshape(regions{n_point},[],num_images),1, 'descend');
    im_peak_means(:,num_regions) = mean(Y3_temp(1:ave_top_num,:));
end

%% sort the data

mode_data = struct('scan_ind', {}, 'mode',{},'weight',{},'Zn',{},'Zm',{},...
    'Y_regions',{},'num_repeat',{},'Y_means',{},'Y_peak_means',{});

for n_reg = 1:num_regions
    temp_reg = regions{n_reg};
    for n_scan = 1:num_images
        mode_data(n_scan).scan_ind = n_scan;
        mode_data(n_scan).mode = scanned_sequence(n_scan,1);
        mode_data(n_scan).weight = scanned_sequence(n_scan,2);
        if scanned_sequence(n_scan,1) == 999
            mode_data(n_scan).Zn = NaN;
            mode_data(n_scan).Zm = NaN;
        else
            mode_data(n_scan).Zn = zernike_table(scanned_sequence(n_scan,1),2);
            mode_data(n_scan).Zm = zernike_table(scanned_sequence(n_scan,1),3);
        end
        mode_data(n_scan).im_regions{n_reg} = temp_reg(:,:,n_scan);
        mode_data(n_scan).im_means(n_reg) = im_means(n_scan,n_reg);
        mode_data(n_scan).im_peak_means(n_reg) = im_peak_means(n_scan,n_reg);
    end
end
for n_mode_ind = 1:num_scanned_modes
    n_mode = scanned_modes(n_mode_ind);
    temp_mode_data = mode_data([mode_data.mode] == n_mode);
    weights = unique([temp_mode_data.weight]');
    for n_w = 1:numel(weights)
        scan_reps_ind = [temp_mode_data([temp_mode_data.weight] == weights(n_w)).scan_ind];
        for n_rep = 1:numel(scan_reps_ind)
            mode_data(scan_reps_ind(n_rep)).num_repeat = n_rep;
        end
    end
end

%%
% mode_data = struct ('mode', 0,'weights', cell(num_scanned_modes,1),...
%     'Zn', 0, 'Zm', 0,...
%     'Y_sort',cell(num_scanned_modes,1),'Y_regions',cell(num_scanned_modes,n_reg),...
%     'Y_reg_means',cell(num_scanned_modes,1),'Y_reg_peaks',cell(num_scanned_modes,1),...
%     'num_ave',1);
% 
% for n_mode_ind = 1:num_scanned_modes
%     n_mode = scanned_modes(n_mode_ind);
%     
%     temp_scan = scanned_sequence(scanned_sequence(:,1) == n_mode,:);
%     [~, sort_ind] = sort(temp_scan(:,2));
%     num_weights = numel(unique(temp_scan(:,2)));
% 
%     im_index = temp_scan(sort_ind,3);
%     weights = reshape(scanned_sequence(im_index,2),[],num_weights)';
%     
%     mode_data(n_mode_ind).mode = temp_scan(1);
%     mode_data(n_mode_ind).weights = weights(:,1);    
%     mode_data(n_mode_ind).Y_sort = reshape(Y(:,:,im_index),dim1,dim2,[],num_weights);
%     mode_data(n_mode_ind).num_ave = round(size(temp_scan,1)/num_weights);
%     for n_reg = 1:num_regions
%         temp_reg = regions{n_reg};
%         [dimr1,dimr2,~] = size(temp_reg);
%         mode_data(n_mode_ind).Y_regions = reshape(temp_reg(:,:,im_index),dimr1,dimr2,[],num_weights);
%         mode_data(n_mode_ind).Y_reg_means{n_mode_ind,n_reg} = reshape(Y_means(im_index,n_reg),[],num_weights);
%         mode_data(n_mode_ind).Y_reg_peaks{n_mode_ind,n_reg} = reshape(Y_peak_means(im_index,n_reg),[],num_weights);
%     end
% end

%%
%ft = fittype( @(a1, b1, c1, x) a1*exp(-((x-b1)/c1).^2) );

% y needs extrasmoothing before processing;
filt_win = 5;

for n_mode_ind = 1:(num_scanned_modes-1)
    n_mode = scanned_modes(n_mode_ind);
    for n_rep = 1:num_reps
        temp_mode_data = mode_data(and([mode_data.mode] == n_mode,[mode_data.num_repeat] == n_rep));
        for n_reg = 1:num_regions                
            weights = sort([temp_mode_data.weight])';
            zero_ind = find(weights == 0);
            plot_weights_ind = [(zero_ind-plot_weights(2)*plot_weights(1)/2):plot_weights(2):zero_ind (zero_ind+1):plot_weights(2):(zero_ind+plot_weights(2)*(plot_weights(1)/2-1))];            
            if plot_images
                if sum(plot_modes == n_mode)
                    fig1 = figure;
                end
            end
            for n_w = 1:numel(weights)
                temp = temp_mode_data([temp_mode_data.weight] == weights(n_w));
                Y_temp = temp_mode_data([temp_mode_data.weight] == weights(n_w)).Y_regions{n_reg}; 
                
                % compute X parameters
                X_mean = mean(Y_temp,1);
                X_mean = X_mean - min(X_mean);
                X_max = max(X_mean);
                X_fwhm = sum(X_mean>(X_max/2));
                %X_fit = fit((1:numel(X_mean))',X_mean_sm,'gauss1');
                
                
                Y_mean = mean(Y_temp,2);
                Y_mean_sm = smooth(Y_mean,filt_win, 'lowess');
                %Y_mean_sm = medfilt1(Y_mean,filt_win);
                Y_mean = Y_mean - min(Y_mean_sm);
                Y_mean_sm = Y_mean_sm - min(Y_mean_sm);
                Y_max = max(Y_mean_sm);
                Y_fwhm = sum(Y_mean_sm>(Y_max/2));
%                 figure; hold on;
%                 plot(Y_mean)
%                 plot(Y_mean_sm)
%                 plot(Y_max*(Y_mean_sm>(Y_max/2)))
                %Y_fit = fit((1:numel(Y_mean))',Y_mean','gauss1');
                
                
                mode_data(temp.scan_ind).X_max(n_reg) = X_max;
                mode_data(temp.scan_ind).X_fwhm(n_reg) = X_fwhm;
                mode_data(temp.scan_ind).Y_max(n_reg) = Y_max;
                mode_data(temp.scan_ind).Y_fwhm(n_reg) = Y_fwhm;
                
                
                if plot_images
                    if sum(plot_modes == n_mode)
                        if sum(n_w == plot_weights_ind)
                            figure(fig1)
                            ax1 = subplot(3,6,find(n_w == plot_weights_ind));
                            imagesc(Y_temp);
                            caxis(y_lim);
                            set(ax1,'xtick',[]);set(ax1,'ytick',[]);
                            ylabel(sprintf('Ymax=%.1f, Yhwm=%.1f',Y_max,Y_fwhm));
                            xlabel(sprintf('Xmax=%.1f, Xhwm=%.1f',X_max,X_fwhm));
                            title(['Weight=' num2str(weights(n_w))]);
                        end
                    end
                end
                if plot_psf_params
                    if sum(plot_modes == n_mode)
                        if weights(n_w) == 0
                            figure; 
                            subplot(3,2,1:2);
                            plot(X_mean); hold on; axis tight;
                            title(['Y mean, max= ' num2str(X_max) ' hwm=' num2str(X_fwhm)]); 
                            plot(ones(numel(X_mean))*X_max/2, 'r');
                            subplot(3,2,3:4);
                            plot(Y_mean); hold on; axis tight;
                            title(['X mean, max= ' num2str(Y_max) ' hwm=' num2str(Y_fwhm)]);
                            plot(Y_mean_sm);
                            plot(ones(numel(Y_mean_sm))*Y_max/2, 'r');
                            subplot(3,2,5);
                            surf(Y_temp); title(['PSF Mode=' num2str(temp.mode) ' Weight=' num2str(weights(plot_weights_ind(n_w)))])
                            sm_Y = conv2(Y_temp, ones(5,5)/5, 'same');
                            subplot(3,2,6);
                            surf(sm_Y); title('Smooth PSF')
                            suptitle(['Region=' num2str(n_reg) ' Mode=' num2str(temp.mode) ' Zn=' num2str(temp.Zn) ' Zm=' num2str(temp.Zm) ' Rep' num2str(temp.num_repeat)])
                        end
                    end
                end
            end
            if plot_images
                if sum(plot_modes == n_mode)
                    figure(fig1)
                    suptitle(['Region=' num2str(n_reg) ' Mode=' num2str(temp.mode) ' Zn=' num2str(temp.Zn) ' Zm=' num2str(temp.Zm) ' Rep' num2str(temp.num_repeat)]);
                end
            end
        end
    end
end

%%
plot_images = 0;
plot_psf_params = 0;
y_lim = [min(Y(:)) max(Y(:))];
plot_modes = 1:15;
plot_weights = [16,1]; % plot 10,including every other one

for n_mode_ind = 1:(num_scanned_modes-1)
    n_mode = scanned_modes(n_mode_ind);
    for n_rep = 1:num_reps
        temp_mode_data = mode_data(and([mode_data.mode] == n_mode,[mode_data.num_repeat] == n_rep));
        for n_reg = 1:num_regions                
            weights = sort([temp_mode_data.weight])';
            zero_ind = find(weights == 0);
            plot_weights_ind = [(zero_ind-plot_weights(2)*plot_weights(1)/2):plot_weights(2):zero_ind (zero_ind+1):plot_weights(2):(zero_ind+plot_weights(2)*(plot_weights(1)/2-1))];            
            if sum(plot_modes == n_mode)
                fig1 = figure;
            end
            for n_w = 1:numel(weights)
                temp = temp_mode_data([temp_mode_data.weight] == weights(n_w));
                Y_temp = temp_mode_data([temp_mode_data.weight] == weights(n_w)).Y_regions{n_reg}; 
                
                % compute X parameters
                X_mean = mean(Y_temp,1);
                X_mean = X_mean - min(X_mean);
                X_max = max(X_mean);
                X_fwhm = sum(X_mean>(X_max/2));
                %X_fit = fit((1:numel(X_mean))',X_mean_sm,'gauss1');
                
                
                Y_mean = mean(Y_temp,2);
                Y_mean_sm = smooth(Y_mean,filt_win, 'lowess');
                %Y_mean_sm = medfilt1(Y_mean,filt_win);
                Y_mean = Y_mean - min(Y_mean_sm);
                Y_mean_sm = Y_mean_sm - min(Y_mean_sm);
                Y_max = max(Y_mean_sm);
                Y_fwhm = sum(Y_mean_sm>(Y_max/2));
%                 figure; hold on;
%                 plot(Y_mean)
%                 plot(Y_mean_sm)
%                 plot(Y_max*(Y_mean_sm>(Y_max/2)))
                %Y_fit = fit((1:numel(Y_mean))',Y_mean','gauss1');
                
                
                mode_data(temp.scan_ind).X_max(n_reg) = X_max;
                mode_data(temp.scan_ind).X_fwhm(n_reg) = X_fwhm;
                mode_data(temp.scan_ind).Y_max(n_reg) = Y_max;
                mode_data(temp.scan_ind).Y_fwhm(n_reg) = Y_fwhm;

                if sum(plot_modes == n_mode)
                    if sum(n_w == plot_weights_ind)
                        figure(fig1)
                        ax1 = subplot(3,6,find(n_w == plot_weights_ind));
                        imagesc(Y_temp);
                        caxis(y_lim);
                        set(ax1,'xtick',[]);set(ax1,'ytick',[]);
                        ylabel(sprintf('Ymax=%.1f, Yfwhm=%.1f',mode_data(temp.scan_ind).Y_max(n_reg),mode_data(temp.scan_ind).Y_fwhm(n_reg)));
                        xlabel(sprintf('Xmax=%.1f, Xfwhm=%.1f',mode_data(temp.scan_ind).X_max(n_reg),mode_data(temp.scan_ind).X_fwhm(n_reg) = X_fwhm));
                        title(['Weight=' num2str(weights(n_w))]);
                    end
                end

                if plot_psf_params
                    if sum(plot_modes == n_mode)
                        if weights(n_w) == 0
                            figure; 
                            subplot(3,2,1:2);
                            plot(X_mean); hold on; axis tight;
                            title(['Y mean, max= ' num2str(X_max) ' hwm=' num2str(X_fwhm)]); 
                            plot(ones(numel(X_mean))*X_max/2, 'r');
                            subplot(3,2,3:4);
                            plot(Y_mean); hold on; axis tight;
                            title(['X mean, max= ' num2str(Y_max) ' hwm=' num2str(Y_fwhm)]);
                            plot(Y_mean_sm);
                            plot(ones(numel(Y_mean_sm))*Y_max/2, 'r');
                            subplot(3,2,5);
                            surf(Y_temp); title(['PSF Mode=' num2str(temp.mode) ' Weight=' num2str(weights(plot_weights_ind(n_w)))])
                            sm_Y = conv2(Y_temp, ones(5,5)/5, 'same');
                            subplot(3,2,6);
                            surf(sm_Y); title('Smooth PSF')
                            suptitle(['Region=' num2str(n_reg) ' Mode=' num2str(temp.mode) ' Zn=' num2str(temp.Zn) ' Zm=' num2str(temp.Zm) ' Rep' num2str(temp.num_repeat)])
                        end
                    end
                end
            end
            if plot_images
                if sum(plot_modes == n_mode)
                    figure(fig1)
                    suptitle(['Region=' num2str(n_reg) ' Mode=' num2str(temp.mode) ' Zn=' num2str(temp.Zn) ' Zm=' num2str(temp.Zm) ' Rep' num2str(temp.num_repeat)]);
                end
            end
        end
    end
end

%%

% plot_images = 1;
% y_lim = [min(Y(:)) max(Y(:))];
% plot_weights = [16,1]; % plot 10,including every other one
% if plot_images
%     for n_mode_ind = 9%:(num_scanned_modes-1)
%         for n_rep = 1:mode_data.num_ave(1)
%             for n_reg = 1:num_regions
%                 n_mode = mode_data.mode(n_mode_ind);
%                 Y_reg = mode_data.Y_regions{n_mode_ind,n_reg};
%                 weights = mode_data.weights{n_mode_ind};
%                 Y_temp = mode_data.Y_regions{n_mode_ind,n_reg};
%                 %Y_temp = squeeze(mean(Y_temp,3));
%                 Y_temp = squeeze(Y_temp(:,:,n_rep,:));
%                 zero_ind = find(weights == 0);
%                 plot_weights_ind = [(zero_ind-plot_weights(2)*plot_weights(1)/2):plot_weights(2):zero_ind (zero_ind+1):plot_weights(2):(zero_ind+plot_weights(2)*(plot_weights(1)/2-1))];            
%                 figure;
%                 for n_w = 1:numel(plot_weights_ind)
%                     subplot(3,6,n_w)
%                     imagesc(Y_temp(:,:,n_w));
%                     caxis(y_lim);
%                     title(['Weight=' num2str(weights(plot_weights_ind(n_w)))]);
%                 end
%                 suptitle(['Region=' num2str(n_reg) ' Mode=' num2str(n_mode) 'n=' num2str(n_mode) 'm=' num2str(n_mode) ' Rep' num2str(n_rep)]);
%             end
%         end
%     end
% end

%% plot means

%y_int_lim = [min(Y_means(:)) max(Y_means(:))];
colors = {'b','r','g', 'y', 'c'};
%mode_data.Y_reg_means_smooth = cell(num_scanned_modes,1);
zernike_computed_weights = struct('mode',{});
plot_traces = 1;
n_reg = 1;
for n_mode_ind = 1:(num_scanned_modes-1)
    n_mode = scanned_modes(n_mode_ind);
    temp_mode_data = mode_data([mode_data.mode] == n_mode);
    [~, temp_ind] = sort([temp_mode_data.weight]);
    temp_mode_data2 = temp_mode_data(temp_ind);
    [~, temp_ind] = sort([temp_mode_data2.num_repeat]);
    temp_mode_data3 = temp_mode_data2(temp_ind);
    
    weights = [temp_mode_data3([temp_mode_data3.num_repeat] == 1).weight];
    X_max = reshape([temp_mode_data3.X_max],[],num_reps);
    Y_max = reshape([temp_mode_data3.Y_max],[],num_reps);
    sm_max = smooth(mean([X_max, Y_max],2),10, 'loess');
    max_ind = find(max(sm_max) == sm_max);
    X_fwhm = reshape([temp_mode_data3.X_hwm],[],num_reps);
    Y_fwhm = reshape([temp_mode_data3.Y_hwm],[],num_reps);
    sm_hwm = smooth(mean([X_fwhm, Y_fwhm],2),10, 'loess');
    hwm_ind = find(min(sm_hwm) == sm_hwm);
    im_means = reshape([temp_mode_data3.Y_means],[],num_reps);
    sm_mean = smooth(mean(im_means,2),10, 'loess');
    mean_ind = find(max(sm_mean) == sm_mean);
    sm_max_hwm_ratio = sm_max./sm_hwm;
    max_hwm_ratio_ind = find(max(sm_max_hwm_ratio) == sm_max_hwm_ratio);
    
    zernike_computed_weights(n_mode_ind).mode = n_mode;
    zernike_computed_weights(n_mode_ind).Zn = temp_mode_data3(1).Zn;
    zernike_computed_weights(n_mode_ind).Zm = temp_mode_data3(1).Zm;
    zernike_computed_weights(n_mode_ind).peak_weight = weights(max_ind);
    zernike_computed_weights(n_mode_ind).hwm_weight = weights(hwm_ind);
    zernike_computed_weights(n_mode_ind).mean_weight = weights(mean_ind);
    zernike_computed_weights(n_mode_ind).max_hwm_ratio_ind = weights(max_hwm_ratio_ind);
    
    if plot_traces
        figure;
        subplot(2,2,1); hold on;
        plot(weights,X_max, 'b');
        plot(weights,Y_max, 'g');
        plot(weights,mean([X_max, Y_max],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_max,'Linewidth',2, 'Color','m');
        plot(weights(max_ind), sm_max(max_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('Xmax and Ymax');

        subplot(2,2,3); hold on;
        plot(weights,X_fwhm, 'b')
        plot(weights,Y_fwhm, 'g')
        plot(weights,mean([X_fwhm, Y_fwhm],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_hwm,'Linewidth',2, 'Color','m');
        plot(weights(hwm_ind), sm_hwm(hwm_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('Xhwm and Yhwm');

        subplot(2,2,2); hold on;
        plot(weights,im_means)
        plot(weights,mean(im_means,2),'Linewidth',2, 'Color','k')
        plot(weights,sm_mean,'Linewidth',2, 'Color','m');
        plot(weights(mean_ind), sm_mean(mean_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('full average');

        subplot(2,2,4); hold on;
        plot(weights,sm_max./sm_hwm,'Linewidth',2, 'Color','m');
        plot(weights(max_hwm_ratio_ind), sm_max_hwm_ratio(max_hwm_ratio_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('max/hwm ratio');
        suptitle(sprintf('zernike mode %d', n_mode));
    end
end



%% % plot peak sig
% %y_int_lim = [min(Y(:)) max(Y(:))];
% colors = {'b','r','g', 'y', 'c'};
% mode_data.Y_reg_peak_smooth = cell(num_scanned_modes,1);
% for n_mode_ind = 1:(num_scanned_modes-1)
%     n_mode = mode_data.mode(n_mode_ind);
%     figure; hold on;
%     Y_temp_peak = mode_data.Y_reg_peaks{n_mode_ind};
%     weights = mode_data.weights{n_mode_ind};
%     sm_intens = smooth(mean(mean(Y_temp_peak,1),3),10, 'loess');
%     mode_data.Y_reg_peak_smooth{n_mode_ind} = sm_intens;
%     [peak_sig, sm_ind] = max(sm_intens);
%     mode_data.zernike_computed_weights(n_mode_ind,3) = weights(sm_ind);
%     for n_pt = 1:num_regions
%         plot(weights,squeeze(Y_temp_peak),colors{n_pt});
%     end
%     plot(weights,mean(mean(Y_temp_peak,1),3),'Linewidth',2, 'Color','k');
%     plot(weights,sm_intens,'Linewidth',2, 'Color','m');
%     plot(weights(sm_ind), peak_sig, '*g','MarkerSize',14,'Linewidth',2);
%     xlabel('weights'); ylabel('signal intensity');% ylim(y_int_lim);
%     title(sprintf('zernike mode %dm max peak w=%.1f', n_mode,weights(sm_ind)));
% end


%%

%zernike_computed_weights = mode_data.zernike_computed_weights;
save([dir_path 'analysis_' load_file_name '.mat'], 'zernike_computed_weights');
