function f_sg_AO_scan_optimization(app)
disp('Starting optimization...');

timestamp = f_sg_get_timestamp();
name_tag = sprintf('%s_%s', app.SavefiletagEditField.Value, timestamp);

%%
ao_params.bead_im_window = app.BeadwindowsizeEditField.Value;
ao_params.intensity_win = 3;
ao_params.n_corrections_to_use = 1;
ao_params.correction_weight_step = 1;
ao_params.plot_stuff = app.PlotprogressCheckBox.Value;
ao_params.plot_stuff_extra = app.PlotextradeetsCheckBox.Value;
ao_params.sigma_pixels = 1;
ao_params.region_name = app.CurrentregionDropDown.Value;
ao_params.file_dir = app.ScanframesdirpathEditField.Value;
ao_params.refocus_every = 100;
ao_params.interate_intens_every = 100;
ao_params.scans_per_mode = app.ScanspermodeEditField.Value;

reg1 = f_sg_get_reg_deets(app, ao_params.region_name);

ao_params.region_params = reg1;
ao_params.init_coord = app.current_SLM_coord;

ao_temp.current_coord = app.current_SLM_coord;
ao_temp.init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;
ao_temp.holo_im_pointer = f_sg_initialize_pointer(app);
ao_temp.reg1 = reg1;

ao_params.name_tag = name_tag;

name_tag2 = sprintf('%s\\%s_z%d',...
            app.SLM_ops.save_AO_dir, name_tag, ao_params.init_coord.xyzp(3));

%% first upload (maybe not needed. already there)

if app.ApplyAOcorrectionButton.Value
    [ao_temp.init_AO_phase, ao_temp.init_AO_correction] = f_sg_AO_get_z_corrections(app, reg1, ao_params.init_coord.xyzp(:,3));
else
    ao_temp.init_AO_correction = [1, 0];
    ao_temp.init_AO_phase = zeros(reg1.SLMm, reg1.SLMn);
end

coord_corr = f_sg_coord_correct(reg1, ao_temp.current_coord);
init_holo_phase = f_sg_PhaseHologram2(coord_corr, reg1);

% convert to exp and slm phase 
complex_exp_corr = exp(1i*(init_holo_phase + ao_temp.init_AO_phase));
SLM_phase_corr = angle(complex_exp_corr);

% apply lut and upload
init_SLM_phase_corr_lut = ao_temp.init_SLM_phase_corr_lut;
init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);

ao_temp.holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, ao_temp.holo_im_pointer);

%%
resetCounters(app.DAQ_session);
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);

%ao_temp.scan_path = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
ao_temp.scan_path = app.ScanframesdirpathEditField.Value;

files1 = dir([ao_temp.scan_path '\' '*tif']);
fnames = {files1.name}';
num_scans_done = numel(fnames);

f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
% make extra scan because stupid scanimage
f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
num_scans_done = num_scans_done + 2;

f_sg_AO_wait_for_frame_convert(ao_temp.scan_path, num_scans_done);

% get all files except last
frames = f_sg_AO_get_all_frames(ao_temp.scan_path);
num_frames = size(frames,3);

ao_temp.f1 = figure; axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
bead_mn = zeros(1,2);
[bead_mn(2),bead_mn(1)] = ginput(1);
bead_mn = round(bead_mn);

% bead window
ao_temp.im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(1));
ao_temp.im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(2));

bead_im = frames(ao_temp.im_m_idx, ao_temp.im_n_idx,num_frames);
deets_pre = f_get_PFS_deets_fast(bead_im, [ao_params.sigma_pixels, ao_params.sigma_pixels]);

ao_params.deets_pre = deets_pre;

ao_temp.bead_mn = bead_mn;
ao_temp.cent_mn = deets_pre.cent_mn;


%% create patterns

max_modes = app.MaxmodesEditField.Value;

zernike_mn_all = f_sg_get_zernike_mode_nm(0:max_modes);
num_modes_all = size(zernike_mn_all ,1);
x_modes_all = 1:num_modes_all;
% generate all polynomials
all_modes = f_sg_gen_zernike_modes(reg1, zernike_mn_all);
ao_temp.all_modes = all_modes;

%% plot

if app.PlotprogressCheckBox.Value
    figure(ao_temp.f1);
    ao_temp.sp1 = cell(2,1);
    ao_temp.sp1{1} = subplot(1,2,1); hold on; axis tight equal;
    imagesc(bead_im);
    plot(ao_temp.cent_mn(2), ao_temp.cent_mn(1), 'ro');
    ao_temp.sp1{2} = subplot(1,2,2); hold on; axis tight;
    plot(0, deets_pre.intensity_raw, '-o');
    pl_idx_line = isprop(ao_temp.sp1{1}.Children, 'LineStyle');
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
    sgtitle(sprintf('%s, z = %.1f', name_tag, ao_params.init_coord.xyzp(3)), 'interpreter', 'none');
end

%% scan
num_iter = app.NumiterationsSpinner.Value;

center_defocus_z_range = (-5:5);
current_modes = 2;

W_step = app.WeightstepEditField.Value;
W_lim_steps = app.WeightlimitEditField.Value/W_step;
W_step_thresh = 0.05;

ao_params.W_step = W_step;
ao_params.W_lim_steps = W_lim_steps;

mode_data_all = cell(app.NumiterationsSpinner.Value,1);
deeps_post = cell(app.NumiterationsSpinner.Value,1);

ao_params.step_size = 10/num_modes_all;
ao_params.ma_num_it = 2;

z_all = zeros(num_iter, 1);
z_all_idx = false(num_iter, 1);
ao_temp.step_size_all = zeros(num_iter, 1);
ao_temp.w_step_all = zeros(num_iter, num_modes_all);
ao_temp.d_w_all = zeros(num_iter, 1);
PSF_all = cell(num_iter, 1);
AO_corrections_all = cell(num_iter, 1);
ao_temp.good_correction = false(num_iter, 1);

refocus_scan = num_scans_done - ao_params.refocus_every - 1; % to do it on first iteration
iter_intens_scan = num_scans_done - ao_params.refocus_every -1;

ao_data.ao_params = ao_params;

reduce_d_w = 0;
added_modes = 0;
num_seq_it = 0;

for n_it = 1:num_iter
    fprintf('Iteration %d; scan %d...\n', n_it, num_scans_done);
    ao_temp.n_it = n_it;
    if reduce_d_w 
        W_step = W_step/2;
    end
    reduce_d_w = 0;
    ao_temp.good_correction(n_it) = 1;
    
    if W_step < W_step_thresh
        added_modes = added_modes + 1;
        W_step = app.WeightstepEditField.Value/(added_modes + 1);
        current_modes = current_modes + 1;
    end
    
    AO_corrections_all2 = [{ao_temp.init_AO_correction}; AO_corrections_all];
    %current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all{:}), ao_temp) + ao_temp.init_AO_phase;
    current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all2{:}), ao_temp);

    ao_temp.current_AO_phase = current_AO_phase;
    
    %% refocus in z
    if (num_scans_done - refocus_scan) > ao_params.refocus_every
        [current_coord, num_scans_done, PSF_all{n_it}] = f_sg_AO_refocus_PSF(app, center_defocus_z_range, num_scans_done, ao_temp, ao_params);
        ao_temp.current_coord = current_coord;
        z_all(n_it) = current_coord.xyzp(3);
        z_all_idx(n_it) = 1;
        refocus_scan = num_scans_done;
    end
    
    current_coord_corr = f_sg_coord_correct(reg1, ao_temp.current_coord);
    current_holo_phase = f_sg_PhaseHologram2(current_coord_corr, reg1);
    ao_temp.current_holo_phase = current_holo_phase;
    %% scan gradient

    if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
        weights1 = (-W_lim_steps*W_step):W_step:(W_lim_steps*W_step);
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential')
        if ~num_seq_it
            weights1 = [-W_step, 0,  W_step];
        else
            weights1 = (-W_lim_steps*W_step):W_step:(W_lim_steps*W_step);
        end
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        weights1 = [-W_step, W_step];
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient3')
        weights1 = [-W_step, 0,  W_step];
    end
    
    zernike_imn = f_sg_AO_get_zernike_imn(current_modes);
    zernike_imn2 = zernike_imn(zernike_imn(:,2) == current_modes,:);
    num_modes2 = size(zernike_imn2,1);
    if num_seq_it
        zernike_imn2 = zernike_imn2(zernike_imn(:,1) == mode_seq(mode_seq_idx),:);
    end
    num_modes = size(zernike_imn2,1);
    
    num_weights = numel(weights1);
    scan_seq1 = cat(3, repmat(zernike_imn2(:,1), [1, num_weights]), ones(num_modes, num_weights).*weights1);
    scan_seq1 = permute(scan_seq1, [2, 1, 3]);
    scan_seq1 = reshape(scan_seq1, [num_modes*num_weights, 2]);
    scan_seq1 = repmat(scan_seq1, [app.ScanspermodeEditField.Value, 1]);
    grad_scan_seq = num2cell(scan_seq1, 2);

    num_scans = size(grad_scan_seq,1);
    if app.ShufflemodesCheckBox.Value
        scan_seq2 = scan_seq1(randsample(num_scans,num_scans),:);
    else
        scan_seq2 = scan_seq1;
    end
    
    grad_scan_seq = num2cell(scan_seq2, 2);
    
    %% scan mode sequence
    num_scans_done2 = f_sg_AO_scan_ao_seq(app, ao_temp.current_AO_phase, grad_scan_seq, ao_temp);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;
    
    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);
    
    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(ao_temp.im_m_idx, ao_temp.im_n_idx, scan_start:scan_end);
    
    %% analyze
    
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
        % process find best mode
        [AO_correction_new, mode_data_all{n_it}] = f_sg_AO_find_best_mode_grid(frames2, grad_scan_seq, ao_params);
    else %if strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        [AO_correction_new, ao_temp] = f_sg_AO_analyze_scan(frames2, grad_scan_seq, ao_params, ao_temp);
    end
    
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential')
        if ~num_seq_it
            num_seq_it = 1;
            [~, idx1] = sort(abs(ao_temp.w_step_all(n_it,:)), 'descend');
            mode_seq = idx1(1:num_modes);
            mode_seq_idx = 1;
        else
            if mode_seq_idx < num_modes2
                mode_seq_idx = mode_seq_idx + 1;
            else
                num_seq_it = 0;
            end
        end
    end

    % update corrections
    AO_corrections_all{n_it} = AO_correction_new;
    %% scan all corrections
    x_intens_scan = 0:n_it;
    scan_seq = x_intens_scan' + 1;
    if or((num_scans_done - iter_intens_scan) > ao_params.interate_intens_every, n_it == app.NumiterationsSpinner.Value)
        iter_intens_scan = num_scans_done;
    else
        scan_seq = scan_seq(end-1:end);
    end
    
    scan_seq2 = repmat(scan_seq, app.ScanspermodeEditField.Value, 1);
    
    x_intens_scan2 = x_intens_scan(scan_seq);
    num_scan_corrections = numel(x_intens_scan2);
    
    num_scans_ver = numel(scan_seq2);

    if app.ShufflemodesCheckBox.Value
        scan_seq2 = scan_seq2(randsample(num_scans_ver,num_scans_ver),:);
    end
    
    AO_corr2 = [{[1 0]}; AO_corrections_all];
    
    scan_seq3 = cell(num_scans_ver, 1);
    for n_seq = 1:num_scans_ver
        scan_seq3{n_seq} = cat(1,AO_corr2{1:scan_seq2(n_seq)});
    end
    
    num_scans_done2 = f_sg_AO_scan_ao_seq(app, ao_temp.init_AO_phase, scan_seq3, ao_temp);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;

    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(ao_temp.im_m_idx, ao_temp.im_n_idx, scan_start:scan_end);
    
%     intens_all = zeros(num_scans_ver,1);
%     for n_scan = 1:num_scans_ver
%         temp_deets = f_get_PFS_deets_fast(frames2(:,:,n_scan), [ao_params.sigma_pixels, ao_params.sigma_pixels]);
%         intens_all(n_scan) = temp_deets.intensity_sm;
%     end
%     intensit2 = zeros(num_scan_corrections,1);
%     for n_fr = 1:num_scan_corrections
%         idx3 = scan_seq2 == n_fr;
%         intensit2(n_fr) = mean(intens_all(idx3));
%     end
    
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
        intensit(n_fr) = mean([deets_corr.intensity_sm]);
    end
    
    
    if or(intensit(end) > intensit(end-1), strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential'))
        ao_temp.good_correction(n_it) = 1;
    else
        reduce_d_w = 1;
        AO_corrections_all(n_it) = {[]};
    end
    
    %AO_corrections_all(~good_correction) = {[]};
    
    if num_scan_corrections == (n_it+1)
        ao_temp.cent_mn = mean([deets_corr.cent_mn],2)';
        bead_im = mean(frames2(:,:,fr_idx1),3);
        deeps_post{n_it} = deets_corr;
        
        ao_temp.bead_mn = ao_temp.bead_mn + round(ao_temp.cent_mn) - [ao_params.bead_im_window/2 ao_params.bead_im_window/2];

        ao_temp.im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + ao_temp.bead_mn(1));
        ao_temp.im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + ao_temp.bead_mn(2));
    end
    
    %% maybe plot
    if app.PlotprogressCheckBox.Value
        figure(ao_temp.f1);
        ao_temp.sp1{1}.Children(~pl_idx_line).CData = bead_im;
        ao_temp.sp1{1}.Children(pl_idx_line).XData = ao_temp.cent_mn(2);
        ao_temp.sp1{1}.Children(pl_idx_line).YData = ao_temp.cent_mn(1);

        subplot(ao_temp.sp1{2});
        plot(x_intens_scan2, intensit, '-o');
    end
    
    ao_data.AO_correction = AO_corrections_all;
    ao_data.good_correction = good_correction;
    ao_data.z_all = z_all;
    ao_data.step_size_all = step_size_all;
    ao_data.w_step_all = w_step_all;
    ao_data.mode_data_all = mode_data_all;
    ao_data.deeps_post = deeps_post;
    ao_data.PSF_all = PSF_all;

    save([name_tag2 '.mat'], 'ao_data', '-v7.3');
end

%% scan PSF at end
current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all{:}), ao_temp) + ao_temp.init_AO_phase;
ao_temp.current_AO_phase = current_AO_phase;

if 0
    psf_z = -10:0.1:10;

    num_scans_done2 = f_sg_AO_scan_z_defocus(app, psf_z, ao_temp);
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

    ao_data.PSF_final = frames2;
end

%%
current_coord_corr = f_sg_coord_correct(reg1, ao_temp.current_coord);
current_holo_phase = f_sg_PhaseHologram2(current_coord_corr, reg1);

complex_exp_corr = exp(1i*(current_holo_phase+current_AO_phase));
SLM_phase_corr = angle(complex_exp_corr);

% apply lut and upload
init_SLM_phase_corr_lut = ao_temp.init_SLM_phase_corr_lut;
init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
ao_temp.holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, ao_temp.holo_im_pointer);

%% save

save([name_tag2 '.mat'], 'ao_data', '-v7.3');
saveas(f1,[name_tag2 'f1.fig']);
saveas(f2,[name_tag2 'f2.fig']);
%% save stuff
disp('Done');
end