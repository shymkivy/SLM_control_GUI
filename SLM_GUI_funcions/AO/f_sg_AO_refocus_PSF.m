function [current_coord, num_scans_done, PSF_frames] = f_sg_AO_refocus_PSF(app, center_defocus_z_range, num_scans_done, ao_temp, ao_params)

fprintf('Refocusing...\n');
n_it = ao_temp.n_it;
current_coord = ao_temp.current_coord;
win_cent = ao_params.bead_im_window/2+1;

[PSF_frames, num_scans_done] = f_sg_AO_scan_z_defocus(app, center_defocus_z_range, num_scans_done, ao_temp);

% analyze
z_range = current_coord.xyzp(3) + center_defocus_z_range;
data_sm = f_smooth_nd(PSF_frames, [ao_params.sigma_pixels ao_params.sigma_pixels ao_params.sigma_pixels]);
y0 = squeeze(data_sm(win_cent, win_cent, :));
[~, peak_idx1] = max(y0);

%yf = fit(z_range' ,y0,'gauss1');
yf = fit(z_range' ,y0,'smoothingspline','SmoothingParam', 1);
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
    imagesc(data_sm(:,:,z_idx_min));
    xlabel(sprintf('z=%.1f', z_range(z_idx_min)));
    subplot(2,3, 2);
    imagesc(data_sm(:,:,peak_idx1));
    xlabel(sprintf('z=%.1f', z_range(peak_idx1)));
    subplot(2,3, 3);
    imagesc(data_sm(:,:,z_idx_max));
    xlabel(sprintf('z=%.1f', z_range(z_idx_max)));
    subplot(2,3, 4:6); hold on;
    plot(z_range, squeeze(data_sm(win_cent, win_cent, :)));
    plot(z_fit, y_fit, 'r')
    plot(current_z, y_fit(peak_idx2), 'go')
    plot(z_range(peak_idx1), data_sm(win_cent, win_cent, peak_idx1), 'ko');
    plot(z_range(z_idx_min), data_sm(win_cent, win_cent, z_idx_min), 'ko');
    plot(z_range(z_idx_max), data_sm(win_cent, win_cent, z_idx_max), 'ko');
    legend('Measured', 'fit', 'computed defocus', 'images')
    xlabel('z location (um)');
    ylabel('PSF Intensity')
    sgtitle(sprintf('Refocusing, new z = %.1f; iter %d', current_coord.xyzp(3), n_it));
end

fprintf('New z = %.1f um\n', current_z);
end