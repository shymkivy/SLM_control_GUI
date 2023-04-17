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

reg1 = f_sg_get_reg_deets(app, ao_params.region_name);

ao_params.region_params = reg1;
ao_params.init_coord = app.current_SLM_coord;

ao_temp.current_coord = app.current_SLM_coord;
ao_temp.init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;
ao_temp.holo_im_pointer = f_sg_initialize_pointer(app);
ao_temp.reg1 = reg1;

name_tag2 = sprintf('%s\\%s_z%d',...
            app.SLM_ops.save_AO_dir, name_tag, ao_params.init_coord.xyzp(3));

%% first upload (maybe not needed. already there)

if app.ApplyAOcorrectionButton.Value
    ao_temp.init_AO_phase = f_sg_AO_get_z_corrections(app, reg1, ao_params.init_coord.xyzp(:,3));
    init_AO_correction = [1, 0];
else
    init_AO_correction = [1, 0];
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

%path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
path1 = app.ScanframesdirpathEditField.Value;
%exist(path1, 'dir');
ao_temp.path1 = path1;

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
    figure(f1);
    sp1 = subplot(1,2,1); hold on; axis tight equal;
    imagesc(bead_im);
    plot(ao_temp.cent_mn(2), ao_temp.cent_mn(1), 'ro');
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
num_iter = app.NumiterationsSpinner.Value;

center_defocus_z_range = (-5:5);
current_coord = ao_params.init_coord;
current_modes = 2;

W_lim = app.WeightlimitEditField.Value;
W_step = app.WeightstepEditField.Value;
W_step_thresh = 0.05;

mode_data_all = cell(app.NumiterationsSpinner.Value,1);
deeps_post = cell(app.NumiterationsSpinner.Value,1);

step_size = 10/num_modes_all;
ma_num_it = 2;

z_all = zeros(num_iter, 1);
z_all_idx = false(num_iter, 1);
step_size_all = zeros(num_iter, 1);
w_step_all = zeros(num_iter, num_modes_all);
PSF_all = cell(num_iter, 1);
d_w_all = zeros(num_iter, 1);
AO_corrections_all = cell(num_iter, 1);
good_correction = false(num_iter, 1);

refocus_scan = num_scans_done - ao_params.refocus_every - 1; % to do it on first iteration
iter_intens_scan = num_scans_done - ao_params.refocus_every -1;

ao_data.ao_params = ao_params;

reduce_d_w = 0;

added_modes = 0;

for n_it = 1:num_iter
    fprintf('Iteration %d; scan %d...\n', n_it, num_scans_done);
    ao_temp.n_it = n_it;
    if reduce_d_w 
        W_step = W_step/2;
    end
    reduce_d_w = 0;
    good_correction(n_it) = 1;
    
    if W_step < W_step_thresh
        added_modes = added_modes + 1;
        W_step = app.WeightstepEditField.Value/(added_modes + 1);
        current_modes = current_modes + 1;
    end
    
    current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all{:}), ao_temp) + ao_temp.init_AO_phase;
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
        weights1 = -W_lim:W_step:W_lim;   
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        weights1 = [-W_step, W_step];
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient3')
        weights1 = [-W_step, 0,  W_step];
    end

    zernike_imn = f_sg_AO_get_zernike_imn(current_modes);
    zernike_imn2 = zernike_imn(zernike_imn(:,2) == current_modes,:);
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

        % can optimize most problematic mode here
        intensity = zeros(num_scans, 1);
        for n_scan = 1:num_scans
            deets1 = f_get_PFS_deets_fast(frames2(:,:,n_scan), [ao_params.sigma_pixels, ao_params.sigma_pixels]);
            intensity(n_scan) = deets1.intensity_sm;
        end
        
        mode_weight_int = [cat(1, grad_scan_seq{:}), intensity];
        
        modes2 = unique(mode_weight_int(:,1));

        if 1
            d_w = zeros(num_modes_all,1);
            d_i = zeros(num_modes_all,1);
            for n_mode = 1:numel(modes2)
                idx1 = mode_weight_int(:,1) == modes2(n_mode);

                x0 = mode_weight_int(idx1,2);
                y0 = mode_weight_int(idx1,3);
                
                x_fit = weights1(1):(W_step/100):weights1(end);
                if 1
                    yf = fit(x0 ,y0, 'smoothingspline','SmoothingParam', 1);
                    [~, idx2] = max(yf(x_fit));
                    peak_loc = x_fit(idx2);
                else
                    yf = fit(x0 ,y0, 'gauss1');
                    peak_loc = yf.b1;
                end

                figure; hold on;
                plot(x0, y0, 'o')
                plot(x_fit, yf(x_fit), '-')
                plot(peak_loc, yf(peak_loc), 'ro')
                title(sprintf('iter %d; mode %d; wstep=%.2f', n_it, modes2(n_mode), peak_loc))
                
                d_w(modes2(n_mode)) = peak_loc;
                d_i(modes2(n_mode)) = yf(peak_loc) - yf(0);
            end
            w_step = d_w .* d_i/sum(d_i);
        else
            [~, sort_idx] = sort(mode_weight_int(:,2));
            mode_weight_int2 = mode_weight_int(sort_idx,:);

            [~, sort_idx2] = sort(mode_weight_int2(:,1));
            mode_weight_int3 = mode_weight_int2(sort_idx2,:);

            mode_weight_int4 = squeeze(mean(reshape(mode_weight_int3, app.ScanspermodeEditField.Value, [], 3),1));
            mode_weight_int5 = reshape(mode_weight_int4, num_weights, [], 3);

            intens2 = mode_weight_int5(:,:,3);
            
            d_w = (weights1(end) - weights1(1));
            d_i = ((intens2(end,:) - intens2(1,:))/mean(intens2(:)))';
            
            grad2 = d_i/d_w;

            w_step2 = grad2*d_w*step_size;
            w_step(modes2) = w_step2;
        end
        
        step_size_all(n_it) = sum(abs(w_step));
        w_step_all(n_it, :) = w_step;
        
        step_size_all(~good_correction,:) = 0;
        w_step_all(~good_correction, :) = 0;
        
        w_step_all_cum = cumsum(w_step_all,1);
        corr_all_weights_ma = zeros(n_it, num_modes_all);
        for n_it2 = 1:(n_it)
            it_start = max(n_it2 - ma_num_it, 1);
            corr_all_weights_ma(n_it2,:) = mean(w_step_all(it_start:n_it2,:),1);
        end
        
        AO_correction_new = [modes2, w_step(modes2)];
        
        d_w_all(n_it) = weights1(end) - weights1(1);
%         if max(abs(corr_all_weights_ma(n_it,:))) < W_step
%             reduce_d_w = 1;
%         end
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
    
    if intensit(end) > intensit(end-1)
        good_correction(n_it) = 1;
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
        figure(f1);
        sp1.Children(~pl_idx_line).CData = bead_im;
        sp1.Children(pl_idx_line).XData = ao_temp.cent_mn(2);
        sp1.Children(pl_idx_line).YData = ao_temp.cent_mn(1);

        subplot(sp2);
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