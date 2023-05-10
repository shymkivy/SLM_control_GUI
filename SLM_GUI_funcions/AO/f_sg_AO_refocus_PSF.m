function [current_coord, num_scans_done, PSF_frames] = f_sg_AO_refocus_PSF(app, center_defocus_z_range, num_scans_done, ao_temp, ao_params)

fprintf('Refocusing...\n');
n_it = ao_temp.n_it;
current_coord = ao_temp.current_coord;
win_cent = ao_params.bead_im_window/2+1;

[PSF_frames, num_scans_done] = f_sg_AO_scan_z_defocus(app, center_defocus_z_range, num_scans_done, ao_temp);

% analyze

z_range = current_coord.xyzp(3) + center_defocus_z_range;
num_fr = numel(z_range);

data_sm = f_smooth_nd(PSF_frames, [ao_params.sigma_pixels ao_params.sigma_pixels ao_params.sigma_pixels]);

clim1 = [min(data_sm(:)) max(data_sm(:))];

mean_fr = mean(data_sm,3);
[~, idx] = max(mean_fr(:));
[mean_row, mean_col] = ind2sub([ao_params.bead_im_window+1, ao_params.bead_im_window+1], idx);

row_all = zeros(num_fr,1);
col_all = zeros(num_fr,1);

for n_fr = 1:num_fr
    fr1 = data_sm(:,:,n_fr);
    [~, idx] = max(fr1(:));
    [row_all(n_fr), col_all(n_fr)] = ind2sub([ao_params.bead_im_window+1, ao_params.bead_im_window+1], idx);
end

exclude1 = or(abs(row_all - mean_row) > 10, abs(col_all - mean_col) > 10);

yfr = fit(z_range(~exclude1)', row_all(~exclude1), 'poly1');
yfc = fit(z_range(~exclude1)', col_all(~exclude1), 'poly1');

% figure; hold on;
% plot(z_range, row_all)
% plot(z_range, yfr(z_range))
% plot(z_range, col_all)
% plot(z_range, yfc(z_range))

row_fit = round(yfr(z_range));
col_fit = round(yfc(z_range));

y0 = zeros(num_fr,1);

for n_fr = 1:num_fr
    y0(n_fr) = data_sm(row_fit(n_fr), col_fit(n_fr), n_fr);
end

[~, peak_idx1] = max(y0);

%yf = fit(z_range' ,y0,'gauss1');
yf = fit(z_range' ,y0,'smoothingspline', 'SmoothingParam', 0.5);
z_fit = z_range(1):0.1:z_range(end);
y_fit = yf(z_fit);

[~, peak_idx2] = max(y_fit);
current_z = z_fit(peak_idx2);

current_coord.xyzp(3) = current_z;

z_idx_min = max(peak_idx1-2,1);
z_idx_max = min(peak_idx1+2,numel(z_range));

if ao_params.plot_stuff
    figure;
    subplot(2,3, 1);
    imagesc(data_sm(:,:,z_idx_min)); hold on;
    caxis(clim1);
    plot(col_fit(z_idx_min), row_fit(z_idx_min), 'ro');
    xlabel(sprintf('z=%.1f', z_range(z_idx_min)));
    subplot(2,3, 2);
    imagesc(data_sm(:,:,peak_idx1)); hold on;
    caxis(clim1);
    plot(col_fit(peak_idx1), row_fit(z_idx_min), 'ro');
    xlabel(sprintf('z=%.1f', z_range(peak_idx1)));
    subplot(2,3, 3);
    imagesc(data_sm(:,:,z_idx_max)); hold on;
    caxis(clim1);
    plot(col_fit(z_idx_max), row_fit(z_idx_max), 'ro');
    xlabel(sprintf('z=%.1f', z_range(z_idx_max)));
    subplot(2,3, 4:6); hold on;
    plot(z_range, y0);
    plot(z_fit, y_fit, 'r')
    plot(current_z, y_fit(peak_idx2), 'go')
    plot(z_range(peak_idx1), data_sm(row_fit(peak_idx1), col_fit(peak_idx1), peak_idx1), 'ko');
    plot(z_range(z_idx_min), data_sm(row_fit(z_idx_min), col_fit(z_idx_min), z_idx_min), 'ko');
    plot(z_range(z_idx_max), data_sm(row_fit(z_idx_max), col_fit(z_idx_max), z_idx_max), 'ko');
    
    legend('Measured', 'fit', 'computed defocus', 'images')
    xlabel('z location (um)');
    ylabel('PSF Intensity')
    sgtitle(sprintf('Refocusing, new z = %.1f; iter %d', current_coord.xyzp(3), n_it));
end

fprintf('New z = %.1f um\n', current_z);
end