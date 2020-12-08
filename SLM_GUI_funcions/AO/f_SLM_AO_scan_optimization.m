function f_SLM_AO_scan_optimization(app)

%%
disp('Starting optimization...');

bead_im_window = 20;

n_corrections_to_use = 1;

sigma_pixels = 1;
kernel_half_size = ceil(sqrt(-log(0.1)*2*sigma_pixels^2));
[X_gaus,Y_gaus] = meshgrid((-kernel_half_size):kernel_half_size);
conv_kernel = exp(-(X_gaus.^2 + Y_gaus.^2)/(2*sigma_pixels^2));
conv_kernel = conv_kernel/sum(conv_kernel(:));
%%
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);
%%
AO_wf = [];
AO_params = struct;
AO_params.AO_iteration = 1;
if app.ApplyAOcorrectionButton.Value
    reg1.AO_correction = app.AOcorrectionDropDown_2.Value;
    [AO_wf, AO_params] = f_SLM_AO_compute_wf(app, reg1);
end
AO_correction = [];

init_image = app.SLM_Image;
SLM_image = f_SLM_AO_add_correction(app, app.SLM_Image, AO_wf);
app.SLM_Image_pointer.Value = f_SLM_im_to_pointer(SLM_image);
f_SLM_BNS_update(app.SLM_ops, app.SLM_Image_pointer);

%%
zernike_table = app.ZernikeListTable.Data;
zernike_table = zernike_table(logical(zernike_table(:,7)),:);

num_modes = size(zernike_table,1);
% cound number of all modes
weights_cell = cell(num_modes,1);
for n_mode = 1:num_modes
    weights_cell{n_mode} = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
end
zernike_table = app.ZernikeListTable.Data;
num_scans = numel(cat(2,weights_cell{:}));
if app.InsertrefimageinscansCheckBox.Value
    num_scans = num_scans + num_modes;
end
num_scans = num_scans * app.ScanspermodeEditField.Value;
%%
num_frames = 0;

%path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
path1 = app.ScanframesdirpathEditField.Value;
exist(path1, 'dir');

scan1 = inputSingleScan(app.DAQ_session);
trig_num = scan1(1)+1;

% trigger first frame
app.DAQ_session.outputSingleScan(5);
app.DAQ_session.outputSingleScan(5);
pause(0.001);
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);


% wait for scan to end
scan1 = inputSingleScan(app.DAQ_session);
trig_num2 = scan1(1)+1;
while trig_num2 <= trig_num
    scan1 = inputSingleScan(app.DAQ_session);
    trig_num2 = scan1(1)+1;
    pause(0.001);
end

% wait for frame to convert
while ~num_frames
    files1 = dir([path1 '\' '*tif']);
    fnames = {files1.name}';
    num_frames = numel(fnames);
    pause(0.005)
end

frames = f_AO_op_get_all_frames(path1);
num_frames = size(frames,3);

figure; axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
bead_mn = zeros(1,2);
[bead_mn(2),bead_mn(1)] = ginput(1);
bead_mn = round(bead_mn);

%%
im_m_idx = (-bead_im_window:bead_im_window) + bead_mn(1);
im_n_idx = (-bead_im_window:bead_im_window) + bead_mn(2);

im_cut = frames(im_m_idx, im_n_idx,num_frames);

deets_pre = f_get_PFS_deets_fast(im_cut, conv_kernel);
intensity_win = ceil((deets_pre.X_fwhm + deets_pre.Y_fwhm)/4);
%%
if app.PlotprogressCheckBox.Value
    sp1 = subplot(1,2,1); hold on; axis tight equal;
    imagesc(im_cut);
    plot(deets_pre.cent_mn(2),deets_pre.cent_mn(1), 'ro');
    sp2 = subplot(1,2,2); axis tight;
    plot(0, deets_pre.intensity_raw);
    pl_idx_line = isprop(sp1.Children, 'LineStyle');
end

%% scan
deets_all = cell(app.NumiterationsSpinner.Value, num_scans);

resetCounters(app.DAQ_session);
pause(0.01);

AO_wf_now = AO_wf;
for n_it = 1:app.NumiterationsSpinner.Value
    [holo_pointers, zernike_scan_sequence] = f_SLM_AO_make_zernike_pointers(app, AO_wf_now);
    fprintf('Iteration %d...\n', n_it);
    for n_scan = 1:num_scans
        scan1 = inputSingleScan(app.DAQ_session);
        trig_num = scan1(1);
        %%
        f_SLM_BNS_update(app.SLM_ops, holo_pointers{n_scan})
        pause(0.005); % wait 3ms for SLM to stabilize
        % send trigger
        app.DAQ_session.outputSingleScan(5);
        app.DAQ_session.outputSingleScan(5);
        pause(0.002);
        app.DAQ_session.outputSingleScan(0);
        app.DAQ_session.outputSingleScan(0);

        % wait for scan to end
        scan1 = inputSingleScan(app.DAQ_session);
        trig_num2 = scan1(1);
        while trig_num2 <= trig_num
            scan1 = inputSingleScan(app.DAQ_session);
            trig_num2 = scan1(1);
            pause(0.001);
        end

        %prairie needs delay to get ready for triggered frame
        pause(0.5);
    end
    %% get frames
    
    while num_frames<=(n_it*num_scans)
        files1 = dir([path1 '\' '*tif']);
        fnames = {files1.name}';
        num_frames = numel(fnames);
        pause(0.005)
    end
    
    frames = f_AO_op_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx,(end-num_scans+1):end);

    %% find best mode and weight
    scanned_modes = unique(zernike_scan_sequence(:,1));
    weights1 = zernike_scan_sequence((zernike_scan_sequence(:,1)==scanned_modes(1)),2);
    num_reps = round(numel(weights1)/numel(unique(weights1)));
    num_scanned_modes = numel(scanned_modes);
    
    mode_data = struct;
    for n_scan = 1:num_scans
        mode_data(n_scan).scan_ind = n_scan;
        mode_data(n_scan).mode = zernike_scan_sequence(n_scan,1);
        mode_data(n_scan).weight = zernike_scan_sequence(n_scan,2);
        if zernike_scan_sequence(n_scan,1) == 999
            mode_data(n_scan).Zn = NaN;
            mode_data(n_scan).Zm = NaN;
        else
            mode_data(n_scan).Zn = zernike_table(zernike_scan_sequence(n_scan,1),2);
            mode_data(n_scan).Zm = zernike_table(zernike_scan_sequence(n_scan,1),3);
        end
        mode_data(n_scan).im = frames2(:,:,n_scan);
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
    for n_scan = 1:num_scans
        deets_all{n_it, n_scan} = f_get_PFS_deets_fast(mode_data(n_scan).im, conv_kernel, intensity_win);
        fnames = fieldnames(deets_all{1,1});
        for n_fl = 1:numel(fnames)
            mode_data(n_scan).(fnames{n_fl}) = deets_all{n_it, n_scan}.(fnames{n_fl});
        end  
    end
    
    zernike_computed_weights = struct('mode',{});
    for n_mode_ind = 1:(num_scanned_modes-1)
        n_mode = scanned_modes(n_mode_ind);
        temp_mode_data = mode_data([mode_data.mode] == n_mode);
        [~, temp_ind] = sort([temp_mode_data.weight]);
        temp_mode_data2 = temp_mode_data(temp_ind);
        [~, temp_ind] = sort([temp_mode_data2.num_repeat]);
        temp_mode_data3 = temp_mode_data2(temp_ind);

        weights = [temp_mode_data3([temp_mode_data3.num_repeat] == 1).weight];
        idx_zero_weight = weights == 0;

        X_peak = reshape([temp_mode_data3.X_peak],[],num_reps);
        Y_peak = reshape([temp_mode_data3.Y_peak],[],num_reps);
        sm_peak = smooth(mean([X_peak, Y_peak],2),10, 'loess');
        [peak_mag, peak_ind] = max(sm_peak);
        peak_change = peak_mag - sm_peak(idx_zero_weight);


        X_fwhm = reshape([temp_mode_data3.X_fwhm],[],num_reps);
        Y_fwhm = reshape([temp_mode_data3.Y_fwhm],[],num_reps);
        sm_fwhm = smooth(mean([X_fwhm, Y_fwhm],2),10, 'loess');
        [fwhm_mag, fwhm_ind] = min(sm_fwhm);
        fwhm_change = fwhm_mag - sm_fwhm(idx_zero_weight);

        im_intens = reshape([temp_mode_data3.intensity_raw],[],num_reps);
        im_intens_sm = smooth(mean(im_intens,2),10, 'loess');
        [intens_mag, intens_ind] = max(im_intens_sm);
        intens_change = intens_mag - im_intens_sm(idx_zero_weight);

        sm_peak_fwhm_ratio = sm_peak./sm_fwhm;
        [peak_fwhm_ratio_mag, peak_fwhm_ratio_ind] = max(sm_peak_fwhm_ratio);
        peak_fwhm_ratio_change = peak_fwhm_ratio_mag - sm_peak_fwhm_ratio(idx_zero_weight);

        sm_peak_x_intens = sm_peak.*im_intens_sm;
        [sm_peak_x_intens_mag, sm_peak_x_intens_ind] = max(sm_peak_x_intens);
        sm_peak_x_intens_change = sm_peak_x_intens_mag - sm_peak_x_intens(idx_zero_weight);

        sm_peak_x_intens_div_fwhm = sm_peak_x_intens./sm_fwhm;
        [sm_peak_x_intens_div_fwhm_mag, sm_peak_x_intens_div_fwhm_ind] = max(sm_peak_x_intens_div_fwhm);
        sm_peak_x_intens_div_fwhm_change = sm_peak_x_intens_div_fwhm_mag - sm_peak_x_intens_div_fwhm(idx_zero_weight);

        zernike_computed_weights(n_mode_ind).mode = n_mode;
        zernike_computed_weights(n_mode_ind).Zn = temp_mode_data3(1).Zn;
        zernike_computed_weights(n_mode_ind).Zm = temp_mode_data3(1).Zm;
        zernike_computed_weights(n_mode_ind).best_peak_weight = weights(peak_ind);
        zernike_computed_weights(n_mode_ind).best_fwhm_weight = weights(fwhm_ind);
        zernike_computed_weights(n_mode_ind).best_intensity_weight = weights(intens_ind);
        zernike_computed_weights(n_mode_ind).best_peak_fwhm_ratio_weight = weights(peak_fwhm_ratio_ind);
        zernike_computed_weights(n_mode_ind).best_sm_peak_x_intens_weight = weights(sm_peak_x_intens_ind);
        zernike_computed_weights(n_mode_ind).sm_peak_x_intens_div_fwhm_weight = weights(sm_peak_x_intens_div_fwhm_ind);
        zernike_computed_weights(n_mode_ind).peak_change = peak_change;
        zernike_computed_weights(n_mode_ind).fwhm_change = fwhm_change;
        zernike_computed_weights(n_mode_ind).intensity_change = intens_change;
        zernike_computed_weights(n_mode_ind).peak_fwhm_ratio_change = peak_fwhm_ratio_change;
        zernike_computed_weights(n_mode_ind).sm_peak_x_intens_change = sm_peak_x_intens_change;
        zernike_computed_weights(n_mode_ind).sm_peak_x_intens_div_fwhm_change = sm_peak_x_intens_div_fwhm_change;
        
        figure;
        subplot(2,3,1); hold on;
        plot(weights,X_peak, 'b');
        plot(weights,Y_peak, 'g');
        plot(weights,mean([X_peak, Y_peak],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_peak,'Linewidth',2, 'Color','m');
        plot(weights(peak_ind), sm_peak(peak_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('X peak and Y peak');

        subplot(2,3,3); hold on;
        plot(weights,X_fwhm, 'b')
        plot(weights,Y_fwhm, 'g')
        plot(weights,mean([X_fwhm, Y_fwhm],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_fwhm,'Linewidth',2, 'Color','m');
        plot(weights(fwhm_ind), sm_fwhm(fwhm_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('X fwhm and Y fwhm');

        subplot(2,3,2); hold on;
        plot(weights,im_intens)
        plot(weights,mean(im_intens,2),'Linewidth',2, 'Color','k')
        plot(weights,im_intens_sm,'Linewidth',2, 'Color','m');
        plot(weights(intens_ind), im_intens_sm(intens_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('intensity');

        subplot(2,3,4); hold on;
        plot(weights,sm_peak./sm_fwhm,'Linewidth',2, 'Color','m');
        plot(weights(peak_fwhm_ratio_ind), sm_peak_fwhm_ratio(peak_fwhm_ratio_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('max/fwhm ratio');
        
        subplot(2,3,5); hold on;
        plot(weights,sm_peak_x_intens,'Linewidth',2, 'Color','m');
        plot(weights(sm_peak_x_intens_ind), sm_peak_x_intens(sm_peak_x_intens_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('peak * intensity');
        suptitle(sprintf('zernike mode %d', n_mode));
    end
    
    [~, best_mode_ind] = sort([zernike_computed_weights.sm_peak_x_intens_div_fwhm_change], 'descend');

    % [~, best_mode_ind] = max([zernike_computed_weights.sm_peak_x_intens_div_fwhm_change]);
    % best_mode = zernike_computed_weights(best_mode_ind).mode;
    % best_mode_w = zernike_computed_weights(best_mode_ind).best_sm_peak_x_intens_weight;

    best_mode = [zernike_computed_weights(best_mode_ind(1:n_corrections_to_use)).mode];
    best_mode_w = [zernike_computed_weights(best_mode_ind(1:n_corrections_to_use)).best_sm_peak_x_intens_weight];

    AO_correction = [AO_correction; best_mode', best_mode_w']
    %% make new wf
    
    %% maybe plot
    if app.PlotprogressCheckBox.Value
        sp1.Children(~pl_idx_line).CData = last_frame(im_m_idx, im_n_idx);
        sp1.Children(pl_idx_line).XData = deets_all{n_it, n_scan}.cent_mn(2);
        sp1.Children(pl_idx_line).YData = deets_all{n_it, n_scan}.cent_mn(1);

        sp2.Children.XData = [sp2.Children.XData; n_it];
        sp2.Children.YData = [sp2.Children.YData; deets_all{n_it, n_scan}.intensity_raw];
    end
end


%% save stuff
disp('Done');
end