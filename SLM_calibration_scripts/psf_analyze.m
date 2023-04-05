clear;
close all;


data_path = 'C:\Users\ys2605\Desktop\stuff\data\ETL_data\etl_psf_prairie1\3_28_23\';


data_path2 = {'z100_20um_256_32ave-003',...
              'z50_20um_256_32ave-002',...
              'z0_20um_256_32ave-001',...
              'z-50_20um_256_32ave-005',...
              'z-100_20um_256_32ave-007'};

title_tag = {'z100', 'z50', 'z0', 'z-50', 'z-100'};



%%
FOV_size = 511; % in um
pix = 256;
zoom = 16;
dz = 0.1; % in um

FOV_half_size = 20;

pix_size = FOV_size/zoom/pix;



%%

num_fil = numel(data_path2);

for n_fil = 1:num_fil
    
    data = f_collect_prairie_tiffs4([data_path, data_path2{n_fil}]);

    
    f1 = figure; imagesc(mean(data,3))
    title('click to select psf');

    [x,y] = ginput(1);
    close(f1)

    data2 = double(data(round(y-FOV_half_size):round(y+FOV_half_size), round(x-FOV_half_size):round(x+FOV_half_size),:));

    baseline = median(reshape(mean(data,3),1,[]));

    data3 = data2 - baseline;

    data_xy = cell(2,1);

    data_xy{1} = squeeze(mean(data3,1));
    data_xy{2} = squeeze(mean(data3,2));

    axis_tag = {'x', 'y'};

    fwhm_xy = zeros(2,1);

    for n_data = 1:2
        data_temp = data_xy{n_data};
        data_temp_mean = mean(data_temp,1);

        [~, peak_loc] = max(data_temp_mean);

        peak_val = max(data_temp(:, peak_loc));

        % take frames with signal
        idx_frames = logical(sum(data_temp > peak_val/5, 1));
        data_temp_mean2 = mean(data_temp(:,idx_frames),2);

        [peak_val2, idx2] = max(data_temp_mean2);

        half_max = peak_val2/2;
        siz1 = numel(data_temp_mean2);
        x = 1:siz1;
        x_ip = 1:0.1:siz1;
        data_x_mean2_ip = interp1(x, data_temp_mean2, x_ip);

        above_hm = data_x_mean2_ip>= half_max;

        hm_pix = x_ip(above_hm);
        fwhm_pix = hm_pix(end) - hm_pix(1);
        fwhm = pix_size * fwhm_pix;

        fwhm_xy(n_data) = fwhm;

        figure; hold on;
        plot(x, data_temp_mean2);
        plot(x_ip, data_x_mean2_ip);
        plot(data_temp_mean2);
        plot(x_ip, above_hm*half_max);
        plot(idx2, data_temp_mean2(idx2), '*')
        legend({'mean trace', 'mean interp', 'above hm', 'peak loc'})
        title(sprintf('%s; %s axis; fwhm = %.2fum', title_tag{n_fil}, axis_tag{n_data}, fwhm));
    end


    fwmh_mean = ceil(mean(fwhm_xy));

    for n_data = 1:2
        data_temp = data_xy{n_data};
        data_temp_mean = mean(data_temp,2);

        [~, peak_loc] = max(data_temp_mean);

        peak_val = max(data_temp(peak_loc,:));

        % take frames with signal
        idx_frames = logical(sum(data_temp > peak_val/5, 2));

        idx_frames = (peak_loc-fwmh_mean):(peak_loc+fwmh_mean);
        data_temp_mean2 = mean(data_temp(idx_frames,:),1);

        [peak_val2, idx2] = max(data_temp_mean2);

        half_max = peak_val2/2;
        siz1 = numel(data_temp_mean2);
        x = 1:siz1;
        x_ip = 1:0.1:siz1;
        data_x_mean2_ip = interp1(x, data_temp_mean2, x_ip);

        above_hm = data_x_mean2_ip>= half_max;

        hm_pix = x_ip(above_hm);
        fwhm_pix = hm_pix(end) - hm_pix(1);
        fwhm = pix_size * fwhm_pix;

        figure; hold on;
        plot(x, data_temp_mean2);
        plot(x_ip, data_x_mean2_ip);
        plot(data_temp_mean2);
        plot(x_ip, above_hm*half_max);
        plot(idx2, data_temp_mean2(idx2), '*')
        legend({'mean trace', 'mean interp', 'above hm', 'peak loc'})
        title(sprintf('%s; z%s axis; fwhm = %.2fum', title_tag{n_fil}, axis_tag{n_data}, fwhm));
    end


end


