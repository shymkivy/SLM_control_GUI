close all;
clear;

dir_path = 'E:\data\SLM\AO\12_1_20\';
mov_name = 'zernike_100umoff_4_3_.5-001';
load_file_name = 'zernike_scan_data_12_1_20_17h_41m';
save_date = '12_1_20';

params.smooth_type = 'gauss';                   %'gauss' or 'mean'
params.intensity_integration = 'halfmax';       % 'halfmax', 'full';
params.fwhm_method = 'smooth_center';           % 'smooth_center', 'marginalize'

params.plot_stuff = 1;

params.pix_size = 500/256/12; % um

params.do_interp = 1;
params.interp_factor = 5;

%%
im_stack = f_collect_prairie_tiffs3([dir_path mov_name]);

load([dir_path load_file_name '.mat']);

%zernike_AO_data.current_correction;
scanned_sequence = zernike_AO_data.zernike_scan_sequence;
zernike_table = zernike_AO_data.zernike_table;
[dim1, dim2, num_images] = size(im_stack);
scanned_sequence = [scanned_sequence, (1:num_images)'];
scanned_modes = unique(scanned_sequence(:,1));
num_scanned_modes = numel(scanned_modes);

weights1 = scanned_sequence((scanned_sequence(:,1)==scanned_modes(1)),2);
num_reps = round(numel(weights1)/numel(unique(weights1)));

%% mark regions
f = figure; imagesc(mean(im_stack,3)); hold on; axis equal tight;
title('Select isolated PSF (2 clicks)');

[x1, y1] = ginput(2);
x1 = round(x1);
y1 = round(y1);
close(f);
coords = [x1, y1];

%% center and square
ds = ceil(max(abs(coords(1,:) - coords(2,:)))/2);

cent_mn = f_get_center(mean(im_stack(y1(1):y1(2),x1(1):x1(2),:),3));
m = cent_mn(1) + y1(1) - 1;
n = cent_mn(2) + x1(1) - 1;

im_stack_cut = im_stack((m-ds):(m+ds),(n-ds):(n+ds),:);
mean_im_stack_cut = mean(im_stack_cut,3);

base_f = min(mean_im_stack_cut(:));
im_stack_cut = im_stack_cut - base_f;
mean_im_stack_cut = mean_im_stack_cut - base_f;

cent_mn = f_get_center(mean_im_stack_cut);
%%
[deets, params] = f_get_PFS_deets(mean_im_stack_cut, params);

%%
im_intens = squeeze(mean(mean(im_stack_cut,1),2));

ave_top_num = 3;
im_temp = sort(reshape(im_stack_cut,[],num_images),1, 'descend');
im_peak_means = mean(im_temp(1:ave_top_num,:));

%% sort the data
mode_data = struct;
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
    mode_data(n_scan).im = im_stack_cut(:,:,n_scan);
    mode_data(n_scan).im_means = im_intens(n_scan);
    mode_data(n_scan).im_peak_means = im_peak_means(n_scan);
end

%%
num_plot_examp = 2;
plot_ind = randsample(num_images, num_plot_examp);

for n_scan = 1:num_images
    
    if sum(n_scan == plot_ind)
        params.plot_stuff = 1;
    else
        params.plot_stuff = 0;
    end
    
    deets2 = f_get_PFS_deets(double(mode_data(n_scan).im), params);
    
    fnames = fieldnames(deets2);
    for n_fl = 1:numel(fnames)
        mode_data(n_scan).(fnames{n_fl}) = deets2.(fnames{n_fl});
    end  
end

%% compute the repeat num
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
plot_images = 1;

y_lim = [min(im_stack(:)) max(im_stack(:))];
plot_modes = 1:15;
plot_weights = [16,1]; % plot 10,including every other one
for n_mode_ind = 1:(num_scanned_modes-1)
    n_mode = scanned_modes(n_mode_ind);
    for n_rep = 1:num_reps
        temp_mode_data = mode_data(and([mode_data.mode] == n_mode,[mode_data.num_repeat] == n_rep));
        weights = sort([temp_mode_data.weight])';
        zero_ind = find(weights == 0);
        plot_weights_ind = [(zero_ind-plot_weights(2)*plot_weights(1)/2):plot_weights(2):zero_ind (zero_ind+1):plot_weights(2):(zero_ind+plot_weights(2)*(plot_weights(1)/2-1))];            
        if sum(plot_modes == n_mode)
            fig1 = figure;
        end
        for n_w = 1:numel(weights)
            temp = temp_mode_data([temp_mode_data.weight] == weights(n_w));
            im_temp = temp_mode_data([temp_mode_data.weight] == weights(n_w)).im; 

            if sum(plot_modes == n_mode)
                if sum(n_w == plot_weights_ind)
                    figure(fig1)
                    ax1 = subplot(3,6,find(n_w == plot_weights_ind));
                    imagesc(im_temp);
                    caxis(y_lim);
                    set(ax1,'xtick',[]);set(ax1,'ytick',[]);
                    ylabel(sprintf('Ymax=%.1f, Yhwm=%.1f',temp.Y_peak,temp.Y_fwhm_um));
                    xlabel(sprintf('Xmax=%.1f, Xhwm=%.1f',temp.X_peak,temp.X_fwhm_um));
                    title(['Weight=' num2str(weights(n_w))]);
                end
            end
        end
        if sum(plot_modes == n_mode)
            figure(fig1)
            suptitle(['Mode=' num2str(temp.mode) ' Zn=' num2str(temp.Zn) ' Zm=' num2str(temp.Zm) ' Rep' num2str(temp.num_repeat)]);
        end
    end
end


%% plot means

%y_int_lim = [min(Y_means(:)) max(Y_means(:))];
colors = {'b','r','g', 'y', 'c'};
%mode_data.Y_reg_means_smooth = cell(num_scanned_modes,1);
zernike_computed_weights = struct('mode',{});
plot_traces = 1;
for n_mode_ind = 1:(num_scanned_modes-1)
    n_mode = scanned_modes(n_mode_ind);
    temp_mode_data = mode_data([mode_data.mode] == n_mode);
    [~, temp_ind] = sort([temp_mode_data.weight]);
    temp_mode_data2 = temp_mode_data(temp_ind);
    [~, temp_ind] = sort([temp_mode_data2.num_repeat]);
    temp_mode_data3 = temp_mode_data2(temp_ind);
    
    weights = [temp_mode_data3([temp_mode_data3.num_repeat] == 1).weight];
    X_peak = reshape([temp_mode_data3.X_peak],[],num_reps);
    Y_peak = reshape([temp_mode_data3.Y_peak],[],num_reps);
    sm_max = smooth(mean([X_peak, Y_peak],2),10, 'loess');
    peak_ind = find(max(sm_max) == sm_max);
    X_fwhm_um = reshape([temp_mode_data3.X_fwhm_um],[],num_reps);
    Y_fwhm_um = reshape([temp_mode_data3.Y_fwhm_um],[],num_reps);
    sm_fwhm = smooth(mean([X_fwhm_um, Y_fwhm_um],2),10, 'loess');
    fwhm_ind = find(min(sm_fwhm) == sm_fwhm);
    im_intens = reshape([temp_mode_data3.intensity_raw],[],num_reps);
    im_intens_sm = smooth(mean(im_intens,2),10, 'loess');
    intens_ind = find(max(im_intens_sm) == im_intens_sm);
    sm_max_fwhm_ratio = sm_max./sm_fwhm;
    max_fwhm_ratio_ind = find(max(sm_max_fwhm_ratio) == sm_max_fwhm_ratio);
    
    zernike_computed_weights(n_mode_ind).mode = n_mode;
    zernike_computed_weights(n_mode_ind).Zn = temp_mode_data3(1).Zn;
    zernike_computed_weights(n_mode_ind).Zm = temp_mode_data3(1).Zm;
    zernike_computed_weights(n_mode_ind).peak_weight = weights(peak_ind);
    zernike_computed_weights(n_mode_ind).hwm_weight = weights(fwhm_ind);
    zernike_computed_weights(n_mode_ind).mean_weight = weights(intens_ind);
    zernike_computed_weights(n_mode_ind).max_hwm_ratio_ind = weights(max_fwhm_ratio_ind);
    
    if plot_traces
        figure;
        subplot(2,2,1); hold on;
        plot(weights,X_peak, 'b');
        plot(weights,Y_peak, 'g');
        plot(weights,mean([X_peak, Y_peak],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_max,'Linewidth',2, 'Color','m');
        plot(weights(peak_ind), sm_max(peak_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('X peak and Y peak');

        subplot(2,2,3); hold on;
        plot(weights,X_fwhm_um, 'b')
        plot(weights,Y_fwhm_um, 'g')
        plot(weights,mean([X_fwhm_um, Y_fwhm_um],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_fwhm,'Linewidth',2, 'Color','m');
        plot(weights(fwhm_ind), sm_fwhm(fwhm_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('X fwhm and Y fwhm');

        subplot(2,2,2); hold on;
        plot(weights,im_intens)
        plot(weights,mean(im_intens,2),'Linewidth',2, 'Color','k')
        plot(weights,im_intens_sm,'Linewidth',2, 'Color','m');
        plot(weights(intens_ind), im_intens_sm(intens_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('intensity');

        subplot(2,2,4); hold on;
        plot(weights,sm_max./sm_fwhm,'Linewidth',2, 'Color','m');
        plot(weights(max_fwhm_ratio_ind), sm_max_fwhm_ratio(max_fwhm_ratio_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('max/fwhm ratio');
        suptitle(sprintf('zernike mode %d', n_mode));
    end
end


%%

%zernike_computed_weights = mode_data.zernike_computed_weights;
save([dir_path 'analysis_' load_file_name '.mat'], 'zernike_computed_weights');
