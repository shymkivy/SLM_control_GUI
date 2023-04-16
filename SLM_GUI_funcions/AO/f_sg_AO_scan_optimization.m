function f_sg_AO_scan_optimization(app)
disp('Starting optimization...');

timestamp = f_sg_get_timestamp();
name_tag = sprintf('%s_%s', app.SavefiletagEditField.Value, timestamp);
refocus_every = 100;
interate_intens_every = 100;
%%
ao_params.bead_im_window = app.BeadwindowsizeEditField.Value;
ao_params.n_corrections_to_use = 1;
ao_params.correction_weight_step = 1;
ao_params.plot_stuff = app.PlotprogressCheckBox.Value;
ao_params.plot_stuff_extra = app.PlotextradeetsCheckBox.Value;
ao_params.sigma_pixels = 1;
ao_params.region_name = app.CurrentregionDropDown.Value;
ao_params.file_dir = app.ScanframesdirpathEditField.Value;

reg1 = f_sg_get_reg_deets(app, ao_params.region_name);

ao_params.region = reg1;
ao_params.init_coord = app.current_SLM_coord;
ao_params.init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;

%% first upload (maybe not needed. already there)
init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;
holo_im_pointer = f_sg_initialize_pointer(app);

if app.ApplyAOcorrectionButton.Value
    init_AO = f_sg_AO_get_z_corrections(app, reg1, ao_params.init_coord.xyzp(:,3));
else
    init_AO = zeros(reg1.SLMm, reg1.SLMn);
end

coord_corr = f_sg_coord_correct(reg1, ao_params.init_coord);
init_holo_phase = f_sg_PhaseHologram2(coord_corr, reg1);

% convert to exp and slm phase 
complex_exp_corr = exp(1i*(init_holo_phase+init_AO));
SLM_phase_corr = angle(complex_exp_corr);

% apply lut and upload
init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, holo_im_pointer);

%%
resetCounters(app.DAQ_session);
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);

%path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
path1 = app.ScanframesdirpathEditField.Value;
%exist(path1, 'dir');

files1 = dir([path1 '\' '*tif']);
fnames = {files1.name}';
num_scans_done = numel(fnames);

f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
% make extra scan because stupid scanimage
f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
num_scans_done = num_scans_done + 2;

f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

% get all files except last
frames = f_sg_AO_get_all_frames(path1);
num_frames = size(frames,3);

f1 = figure; axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
bead_mn = zeros(1,2);
[bead_mn(2),bead_mn(1)] = ginput(1);
bead_mn = round(bead_mn);

%% bead window
% kernel_half_size = ceil(sqrt(-log(0.1)*2*ao_params.sigma_pixels^2));
% [X_gaus,Y_gaus] = meshgrid((-kernel_half_size):kernel_half_size);
% conv_kernel = exp(-(X_gaus.^2 + Y_gaus.^2)/(2*ao_params.sigma_pixels^2));
% conv_kernel = conv_kernel/sum(conv_kernel(:));

im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(1));
im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(2));

im_cut = frames(im_m_idx, im_n_idx,num_frames);

deets_pre = f_get_PFS_deets_fast(im_cut, [ao_params.sigma_pixels, ao_params.sigma_pixels]);

%ao_params.intensity_win = ceil((deets_pre.X_fwhm + deets_pre.Y_fwhm)/4);
ao_params.intensity_win = 3;
ao_params.deets_pre = deets_pre;



%% create patterns
zernike_table = app.ZernikeListTable.Data;
zernike_table2 = zernike_table(logical(zernike_table(:,7)),:);

% generate all polynomials
all_modes = f_sg_gen_zernike_modes(reg1, zernike_table);
ao_params.all_modes = all_modes;

num_modes_all = size(zernike_table,1);
x_modes_all = 1:num_modes_all;
num_modes = size(zernike_table2,1);

W_step = app.WeightstepEditField.Value;
if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
    W_lim = app.WeightlimitEditField.Value;
    weights1 = -W_lim:W_step:W_lim;   
elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
    weights1 = [-W_step, W_step];
end



%% plot
cent_mn = deets_pre.cent_mn;
if app.PlotprogressCheckBox.Value
    figure(f1);
    sp1 = subplot(1,2,1); hold on; axis tight equal;
    imagesc(im_cut);
    plot(deets_pre.cent_mn(2),deets_pre.cent_mn(1), 'ro');
    sp2 = subplot(1,2,2); hold on; axis tight;
    plot(0, deets_pre.intensity_raw, '-o');
    pl_idx_line = isprop(sp1.Children, 'LineStyle');
    sgtitle(sprintf('%s, z = %.1f', name_tag, ao_params.init_coord.xyzp(3)), 'interpreter', 'none');
    
    f2 = figure();
    sp21 = subplot(5,1,1);
    plot(0, ao_params.init_coord.xyzp(3), 'k-o');
    xlabel('iteration');
    ylabel('z location (um)');
    sp22 = subplot(5,1,2);
    plot(0, 0, 'k-o');
    xlabel('iteration');
    ylabel('total step size (w)');
    sp23 = subplot(5,1,3);
    plot(x_modes_all, zeros(num_modes_all,1), 'k');
    xlabel('all modes');
    ylabel('cumul corr weight');
    sp24 = subplot(5,1,4);
    plot(x_modes_all, zeros(num_modes_all,1), 'k');
    xlabel('all modes');
    ylabel('corr step size');
    sp25 = subplot(5,1,5);
    plot(x_modes_all, zeros(num_modes_all,1), 'k');
    xlabel('all modes');
    ylabel('ma step size');
    sgtitle(sprintf('%s, z = %.1f', name_tag, ao_params.init_coord.xyzp(3)), 'interpreter', 'none');
end

%% scan
AO_correction = {[1, 0]};

center_defocus_z_range = (-5:5);
current_coord = ao_params.init_coord;
win_cent = ao_params.bead_im_window/2+1;

mode_data_all = cell(app.NumiterationsSpinner.Value,1);
deeps_post = cell(app.NumiterationsSpinner.Value,1);

step_size = 10/num_modes_all;
ma_num_it = 2;

d_w_fac = 1;

z_all = zeros(app.NumiterationsSpinner.Value, 1);
z_all_idx = false(app.NumiterationsSpinner.Value, 1);
step_size_all = zeros(app.NumiterationsSpinner.Value, 1);
w_step_all = zeros(app.NumiterationsSpinner.Value, num_modes_all);
PSF_all = cell(app.NumiterationsSpinner.Value, 1);
d_w_all = zeros(app.NumiterationsSpinner.Value, 1);

refocus_scan = num_scans_done;
iter_intens_scan = num_scans_done;
for n_it = 1:app.NumiterationsSpinner.Value
    fprintf('Iteration %d; scan %d...\n', n_it,num_scans_done);
    ao_params.iteration = n_it;
    
    current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_correction{:,1}), ao_params) + init_AO;
    
    %% refocus in z
    if (num_scans_done - refocus_scan) > refocus_every
        num_scans_done2 = f_sg_AO_scan_z_defocus(app, holo_im_pointer, current_coord, center_defocus_z_range, current_AO_phase, ao_params);
        scan_start = num_scans_done + 1;
        scan_end = (scan_start+num_scans_done2-1);
        num_scans_done = num_scans_done + num_scans_done2;

        % make extra scan because stupid scanimage
        f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
        num_scans_done = num_scans_done + 1;
        f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

        % load scanned frames
        frames = f_sg_AO_get_all_frames(path1);
        frames2 = frames(im_m_idx, im_n_idx, scan_start:scan_end);

        PSF_all{n_it} = frames2;

        % analyze
        z_range = current_coord.xyzp(3) + center_defocus_z_range;
        data_sm = f_smooth_nd(frames2, [ao_params.sigma_pixels ao_params.sigma_pixels ao_params.sigma_pixels]);
        y0 = squeeze(data_sm(win_cent, win_cent, :));
        [~, peak_idx1] = max(y0);

        %yf = fit(z_range' ,y0,'gauss1');
        yf = fit(z_range' ,y0,'smoothingspline','SmoothingParam', 1);
        z_fit = z_range(1):0.1:z_range(end);
        y_fit = yf(z_fit);

        [~, peak_idx2] = max(y_fit);
        current_z = z_fit(peak_idx2);

        z_all(n_it) = current_z;
        z_all_idx(n_it) = 1;

        current_coord.xyzp(3) = current_z;

        z_idx_min = max(peak_idx1-2,1);
        z_idx_max = min(peak_idx1+2,numel(z_range));

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
        
        refocus_scan = num_scans_done;
    end
    
    current_coord_corr = f_sg_coord_correct(reg1, current_coord);
    current_holo_phase = f_sg_PhaseHologram2(current_coord_corr, reg1);
    
    %% scan gradient
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        weights1 = [-W_step, W_step];
    end
    
    num_weights = numel(weights1);
    scan_seq1 = cat(3, repmat(zernike_table2(:,1), [1, num_weights]), ones(num_modes, num_weights).*weights1);
    scan_seq1 = permute(scan_seq1, [2, 1, 3]);
    scan_seq1 = reshape(scan_seq1, [num_modes*num_weights, 2]);
    scan_seq1 = repmat(scan_seq1, [app.ScanspermodeEditField.Value, 1]);
    zernike_scan_sequence = num2cell(scan_seq1, 2);

    num_scans = size(zernike_scan_sequence,1);
    if app.ShufflemodesCheckBox.Value
        zernike_scan_sequence2 = zernike_scan_sequence(randsample(num_scans,num_scans));
    else
        zernike_scan_sequence2 = zernike_scan_sequence;
    end
    % scan mode sequence
    num_scans_done2 = f_sg_AO_scan_ao_seq(app, holo_im_pointer, current_holo_phase, current_AO_phase, zernike_scan_sequence2, ao_params);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;
    
    
    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);
    
    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx, scan_start:scan_end);
    
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
        % process find best mode
        [AO_correction_new, mode_data_all{n_it}] = f_sg_AO_find_best_mode_grid(frames2, zernike_scan_sequence2, ao_params);
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        % can optimize most problematic mode here
        intensity = zeros(num_scans, 1);
        for n_scan = 1:num_scans
            deets1 = f_get_PFS_deets_fast(frames2(:,:,n_scan), [ao_params.sigma_pixels, ao_params.sigma_pixels]);
            intensity(n_scan) = deets1.intensity_sm;
        end
        
        mode_weight_int = [cat(1, zernike_scan_sequence2{:}), intensity];
        
        [~, sort_idx] = sort(mode_weight_int(:,2));
        mode_weight_int2 = mode_weight_int(sort_idx,:);
        
        [~, sort_idx2] = sort(mode_weight_int2(:,1));
        mode_weight_int3 = mode_weight_int2(sort_idx2,:);
        
        mode_weight_int4 = squeeze(mean(reshape(mode_weight_int3, app.ScanspermodeEditField.Value, [], 3),1));
        mode_weight_int5 = reshape(mode_weight_int4, 2, [], 3);
        
        modes2 = mode_weight_int5(1, :, 1)';
        weights2 = mode_weight_int5(:, 1, 2);
        
        intens2 = mode_weight_int5(:,:,3);
        d_w = (weights1(2) - weights1(1))/d_w_fac;
        d_i = ((intens2(2,:) - intens2(1,:))/mean(intens2(:)))';
        
        grad2 = d_i/d_w;

        w_step = grad2*d_w*step_size;
        step_size_all(n_it) = sum(abs(w_step));
        w_step_all(n_it,modes2) = w_step;
        w_step_all_cum = cumsum(w_step_all,1);
        corr_all_weights_ma = zeros(n_it, num_modes_all);
        for n_it2 = 1:(n_it)
            it_start = max(n_it2 - ma_num_it, 1);
            corr_all_weights_ma(n_it2,:) = mean(w_step_all(it_start:n_it2,:),1);
        end
        
        AO_correction_new = [modes2, w_step];
        
        d_w_all(n_it) = d_w;
        if max(abs(corr_all_weights_ma(n_it,:))) < W_step
            W_step = W_step/2;
        end
    end
    
    x_it = 1:n_it;
    
    figure(f2)
    subplot(sp21)
    plot([0 x_it(z_all_idx)], [ao_params.init_coord.xyzp(3); z_all(z_all_idx)], 'k-o');
    xlabel('iteration');
    ylabel('z location (um)');
    
    subplot(sp22); hold off;
    plot([0 x_it], [0; step_size_all(x_it)], 'k-o'); hold on;
    plot(x_it, d_w_all(x_it));
    xlabel('iteration');
    ylabel('w mag');
    legend('total step size', 'd_w', 'location', 'northwest');
    
    color1 = gray(n_it+2);
    subplot(sp23); hold off;
    plot(x_modes_all, zeros(num_modes_all, 1), '-o', 'color', color1(n_it+1,:)); hold on;
    for n_it2 = 1:n_it
        plot(x_modes_all, w_step_all_cum(n_it2,:), '-o', 'color', color1(n_it+1-n_it2,:));
    end
    plot(x_modes_all, w_step_all_cum(n_it2,:), 'r-o');
    xlabel('all modes');
    ylabel('cumul corr weight');
    
    subplot(sp24);
    plot(x_modes_all, zeros(num_modes_all, 1), '-o', 'color', color1(n_it+1,:)); hold on;
    for n_it2 = 1:n_it
        plot(x_modes_all, w_step_all(n_it2,:), '-o', 'color', color1(n_it+1-n_it2,:));
    end
    plot(x_modes_all, w_step_all(n_it2,:), 'r-o');
    xlabel('all modes');
    ylabel('corr step size');
    
    
    subplot(sp25)
    plot(x_modes_all, zeros(num_modes_all, 1), '-o', 'color', color1(n_it+1,:)); hold on;
    for n_it2 = 1:n_it
        plot(x_modes_all, corr_all_weights_ma(n_it2,:), '-o', 'color', color1(n_it+1-n_it2,:));
    end
    plot(x_modes_all, corr_all_weights_ma(n_it2,:), 'r-o');
    xlabel('all modes');
    ylabel('ma step size');
    
    % update corrections
    AO_correction = [AO_correction; {AO_correction_new}];
    %% scan all corrections
    num_corrections = numel(AO_correction);
    
    x_intens_scan = 0:(numel(AO_correction)-1);
    if or((num_scans_done - iter_intens_scan) > interate_intens_every, n_it == app.NumiterationsSpinner.Value)
        scan_seq = repmat(1:num_corrections, 1, app.ScanspermodeEditField.Value)';
        iter_intens_scan = num_scans_done;
    else
        scan_seq = repmat(num_corrections, 1, app.ScanspermodeEditField.Value)';
    end
    
    x_intens_scan2 = unique(x_intens_scan(scan_seq));
    num_scan_corrections = numel(x_intens_scan2);
    
    num_scans_ver = numel(scan_seq);

    if app.ShufflemodesCheckBox.Value
        scan_seq2 = scan_seq(randsample(num_scans_ver,num_scans_ver),:);
    else
        scan_seq2 = scan_seq;
    end
    
    scan_seq3 = cell(num_scans_ver, 1);
    for n_seq = 1:num_scans_ver
        scan_seq3{n_seq} = cat(1,AO_correction{1:scan_seq2(n_seq),1});
    end
    
    num_scans_done2 = f_sg_AO_scan_ao_seq(app, holo_im_pointer, current_holo_phase, init_AO, scan_seq3, ao_params);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;

    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx, scan_start:scan_end);
    
    intensit = zeros(num_scan_corrections,1);
    for n_fr = 1:num_scan_corrections
        fr_idx1 = find(scan_seq2 == (x_intens_scan2(n_fr)+1));
        for n_fr2 = 1:numel(fr_idx1)
            temp_deets = f_get_PFS_deets_fast(frames2(:,:,fr_idx1(n_fr2)), [ao_params.sigma_pixels, ao_params.sigma_pixels]);
            if n_fr2 == 1
                deets_corr = temp_deets;
            else
                deets_corr(n_fr2) = temp_deets;
            end
        end
        intensit(n_fr) = mean([deets_corr.intensity_raw]);
    end
    
    if num_scan_corrections == num_corrections
        cent_mn = mean([deets_corr.cent_mn],2)';
        im_cut = mean(frames2(:,:,fr_idx1),3);
        deeps_post{n_it} = deets_corr;
        
        bead_mn = bead_mn + round(cent_mn) - [ao_params.bead_im_window/2 ao_params.bead_im_window/2];

        im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(1));
        im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(2));
    end
    
    %% maybe plot
    if app.PlotprogressCheckBox.Value
        figure(f1);
        sp1.Children(~pl_idx_line).CData = im_cut;
        sp1.Children(pl_idx_line).XData = cent_mn(2);
        sp1.Children(pl_idx_line).YData = cent_mn(1);

        subplot(sp2);
        plot(x_intens_scan2, intensit, '-o');
    end
end

ao_params.z_all = z_all;
ao_params.step_size_all = step_size_all;
ao_params.w_step_all = w_step_all;
ao_params.mode_data_all = mode_data_all;
ao_params.deeps_post = deeps_post;
ao_params.PSF_all = PSF_all;

%% scan PSF at end
current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_correction{:,1}), ao_params) + init_AO;

if 0
    psf_z = -15:0.1:15;

    num_scans_done2 = f_sg_AO_scan_z_defocus(app, holo_im_pointer, current_coord, psf_z, current_AO_phase, ao_params);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;

    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx, scan_start:scan_end);

    ao_params.PSF_final = frames2;
end

%%
current_coord.xyzp(3) = current_z;
current_coord_corr = f_sg_coord_correct(reg1, current_coord);
current_holo_phase = f_sg_PhaseHologram2(current_coord_corr, reg1);

complex_exp_corr = exp(1i*(current_holo_phase+current_AO_phase));
SLM_phase_corr = angle(complex_exp_corr);

% apply lut and upload
init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, holo_im_pointer);

%% save

name_tag2 = sprintf('%s\\%s_%s_z%d',...
            app.SLM_ops.save_AO_dir, name_tag, ao_params.init_coord.xyzp(3));

save([name_tag2 '.mat'], 'AO_correction', 'ao_params', '-v7.3');
saveas(f1,[name_tag2 'f1.fig']);
saveas(f2,[name_tag2 'f2.fig']);
%% save stuff
disp('Done');
end