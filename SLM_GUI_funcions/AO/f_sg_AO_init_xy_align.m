function [num_scans_done, ao_temp, ao_params] = f_sg_AO_init_xy_align(app, ao_temp, ao_params)

files1 = dir([ao_temp.scan_path '\' '*tif']);
fnames = {files1.name}';
num_scans_done = numel(fnames);

f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value, ao_params.use_counter);
% make extra scan because stupid scanimage
f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value, ao_params.use_counter);
num_scans_done = num_scans_done + 2;

f_sg_AO_wait_for_frame_convert(ao_temp.scan_path, num_scans_done);

% get all files except last
frames = f_sg_AO_get_all_frames(ao_temp.scan_path);
num_frames = size(frames,3);

ao_temp.f1 = figure; 
axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
bead_mn = zeros(1,2);
[bead_mn(2),bead_mn(1)] = ginput(1);
bead_mn = round(bead_mn);

% bead window
ao_temp.im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(1));
ao_temp.im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(2));

ao_temp.bead_im = frames(ao_temp.im_m_idx, ao_temp.im_n_idx,num_frames);
deets_pre = f_get_PFS_deets_fast(ao_temp.bead_im, [ao_params.sigma_pixels, ao_params.sigma_pixels]);

ao_params.deets_pre = deets_pre;
ao_temp.bead_mn = bead_mn;
ao_temp.cent_mn = deets_pre.cent_mn;

%% plot

if ao_params.intensity_use_peak
    intens = deets_pre.intensity_peak;
else
    intens = deets_pre.intensity_mean_sm;
end

num_modes_all = size(ao_temp.zernike_nm_all ,1);
x_modes_all = 1:num_modes_all;

if app.PlotprogressCheckBox.Value
    figure(ao_temp.f1);
    ao_temp.sp1 = cell(2,1);
    ao_temp.sp1{1} = subplot(1,2,1); hold on; axis tight equal;
    imagesc(ao_temp.bead_im);
    ao_temp.sp1{1}.YAxis.Direction = 'reverse';
    plot(ao_temp.cent_mn(2), ao_temp.cent_mn(1), 'ro');
    ao_temp.sp1{2} = subplot(1,2,2); hold on; axis tight;
    plot(0, intens, '-o');
    ao_temp.pl_idx_line = isprop(ao_temp.sp1{1}.Children, 'LineStyle');
    sgtitle(sprintf('%s, z = %.1f', ao_params.name_tag, ao_params.init_coord.xyzp(3)), 'interpreter', 'none');
    
    ao_temp.f2 = figure();
    ao_temp.sp2 = cell(5,1);
    ao_temp.sp2{1} = subplot(5,1,1);
    plot(0, ao_params.init_coord.xyzp(3), 'k-o');
    xlabel('iteration');
    ylabel('z location (um)');
    ao_temp.sp2{2} = subplot(5,1,2);
    plot(0, 0, 'k-o');
    xlabel('iteration');
    ylabel('total step size (w)');
    ao_temp.sp2{3} = subplot(5,1,3);
    plot(x_modes_all, zeros(num_modes_all,1), 'k');
    xlabel('all modes');
    ylabel('cumul corr weight');
    ao_temp.sp2{4} = subplot(5,1,4);
    plot(x_modes_all, zeros(num_modes_all,1), 'k');
    xlabel('all modes');
    ylabel('corr step size');
    ao_temp.sp2{5} = subplot(5,1,5);
    plot(x_modes_all, zeros(num_modes_all,1), 'k');
    xlabel('all modes');
    ylabel('ma step size');
    sgtitle(sprintf('%s, z = %.1f', ao_params.name_tag, ao_params.init_coord.xyzp(3)), 'interpreter', 'none');
end

end