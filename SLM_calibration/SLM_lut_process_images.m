clear;close all;

load_path = 'E:\data\SLM\lut_calibration\';
save_path = 'E:\data\SLM\lut_calibration\';

save_fname = 'lut_1064_slm5221_fianium_4r_10_26_20_14h_54m';

im_stack_fname = 'lut_images_1064_slm5221_fianium_4r_10_26_20_14h_54m.mat';
region_gray_fname = 'lut_1064_slm5221_fianium_4r_10_26_20_14h_54m.mat';

z_thresh = .6;
plot_stuff = 1;

slm_roi = 'left_half'; % 'full' 'left_half'(1064) 'right_half'(940)



%%
load([load_path im_stack_fname]);
load([load_path region_gray_fname]);
if size(calib_im_series,3) > size(region_gray,1)
    calib_im_series(:,:,1) = [];
end


%%
regions_run = unique(region_gray(:,1));

for n_reg = 1:numel(regions_run)
    Region = regions_run(n_reg);

    region_gray_ss = region_gray(region_gray(:,1) == Region);
    im_ss = calib_im_series(:,:,region_gray(:,1) == Region);
    
    if ~exist('pt_zero_ord', 'var')
        mean_fr = mean(im_ss,3);
        f1 = figure;
        imagesc(mean_fr');axis image;
        title('Select the zero point');
        pt_zero_ord = ginput(1);
        f1.Children.CLim = f1.Children.CLim/20;
        title('Select the first order point');
        pt_first_ord = ginput(1);
        close(f1);
    end

    if plot_stuff
        figure; imagesc(mean(im_ss,3));
        title(['region ' num2str(Region)]);

        figure;
        plot_int = floor(size(im_ss,3)/6);
        for n_plot = 1:6
            interval = (plot_int*(n_plot-1)+1):(plot_int*n_plot);
            subplot(2,3,n_plot);
            imagesc(mean(im_ss(:,:,interval),3));axis image;
            title(sprintf('Gray pix %d-%d', interval(1), interval(end)));
        end
    end

    %%
    f_trace0 = f_lut_get_mean_intensity(im_ss, pt_zero_ord, z_thresh, 1, 'conv_max'); % 'max_fwhm', 'gauss_fit'
    f_trace1 = f_lut_get_mean_intensity(im_ss, pt_first_ord, z_thresh, 1, 'conv_max'); % 'conv', 'max_fwhm', 'gauss_fit'
    gray_ind = (1:size(im_ss,3))'-1;

    %%
    fold_dir = [save_path '\' save_fname '\zero_ord\'];
    if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
    csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [gray_ind f_trace0]);

    fold_dir = [save_path '\' save_fname '\first_ord\'];
    if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
    csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [gray_ind f_trace1]);
end



