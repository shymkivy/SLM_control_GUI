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
ao_params.interate_intens_every = 200;
ao_params.scans_per_mode = app.ScanspermodeEditField.Value;
ao_params.shuff_scan = app.ShufflemodesCheckBox.Value;
ao_params.intensity_use_peak = 0;

reg1 = f_sg_get_reg_deets(app, ao_params.region_name);

ao_params.region_params = reg1;
ao_params.init_coord = app.current_SLM_coord;

ao_temp.current_coord = app.current_SLM_coord;
ao_temp.init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;
ao_temp.holo_im_pointer = f_sg_initialize_pointer(app);
ao_temp.reg1 = reg1;
ao_temp.scan_path = app.ScanframesdirpathEditField.Value;

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

if reg1.zero_outside_phase_diameter
    SLM_phase_corr(~reg1.holo_mask) = 0;
end

% apply lut and upload
init_SLM_phase_corr_lut = ao_temp.init_SLM_phase_corr_lut;
init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);

ao_temp.holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, ao_temp.holo_im_pointer);

%% create patterns

max_Zn = app.MaxZnEditField.Value;
zernike_nm_all = f_sg_get_zernike_mode_nm(0:max_Zn);
num_modes_all = size(zernike_nm_all ,1);
% generate all polynomials
all_modes_phase = f_sg_gen_zernike_modes(reg1, zernike_nm_all);
ao_temp.all_modes = all_modes_phase;

zernike_imn = f_sg_AO_get_zernike_imn(max_Zn);

ao_temp.zernike_nm_all = zernike_nm_all;
 
%%
resetCounters(app.DAQ_session);
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);

[num_scans_done,ao_temp, ao_params] = f_sg_AO_init_xy_align(app, ao_temp, ao_params);

%% scan
num_iter = app.NumiterationsSpinner.Value;

center_defocus_z_range = (-5:5);

init_W_step = app.WeightstepEditField.Value;
W_step = init_W_step;
W_lim_steps = app.WeightlimitEditField.Value/W_step;
W_step_thresh = 0.05;

ao_params.W_step = W_step;
ao_params.W_lim_steps = W_lim_steps;

mode_data_all = cell(app.NumiterationsSpinner.Value,1);
deeps_post = cell(app.NumiterationsSpinner.Value,1);
PSF_all = cell(num_iter, 1);

ao_params.step_size = 10/num_modes_all;
ao_params.ma_num_it = 2;

ao_temp.z_all = zeros(num_iter, 1);
ao_temp.z_all_idx = false(num_iter, 1);

currentZn = 2;
currentZm_seq = 1;
Zn_all = zeros(num_iter, 1);
Zm_all = zeros(num_iter, 1);
num_W_step_reps = 3;
Zm_seq_all = cell(num_iter,1);
grad3_weights = 1;

ao_temp.step_size_all = zeros(num_iter, 1);
ao_temp.w_step_all = zeros(num_iter, num_modes_all);
ao_temp.d_w_all = zeros(num_iter, 1);
ao_data.intensity_x_all = cell(num_iter,1);
ao_data.intensity_all = cell(num_iter,1);

AO_corrections_all = cell(num_iter, 1);
ao_temp.good_correction = false(num_iter, 1);

num_refocus_scan = num_scans_done - ao_params.refocus_every - 1; % to do it on first iteration
num_iter_intens_scan = num_scans_done - ao_params.refocus_every -1;
reduce_w_step_fac = 1;


make_scan = 1;
step_fac = 1;
ao_data.ao_params = ao_params;

for n_it = 1:num_iter
    fprintf('Iteration %d; scan %d...\n', n_it, num_scans_done);
    ao_temp.n_it = n_it;
    ao_temp.good_correction(n_it) = 1;
    
    %% update AO phase
    AO_corrections_all2 = [{ao_temp.init_AO_correction}; AO_corrections_all];
    %current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all{:}), ao_temp) + ao_temp.init_AO_phase;
    current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all2{:}), ao_temp);
    ao_temp.current_AO_phase = current_AO_phase;
    
    %% refocus in z
    if (num_scans_done - num_refocus_scan) > ao_params.refocus_every
        [current_coord, num_scans_done, PSF_all{n_it}] = f_sg_AO_refocus_PSF(app, center_defocus_z_range, num_scans_done, ao_temp, ao_params);
        ao_temp.current_coord = current_coord;
        ao_temp.z_all(n_it) = current_coord.xyzp(3);
        ao_temp.z_all_idx(n_it) = 1;
        num_refocus_scan = num_scans_done;
    end
    
    current_coord_corr = f_sg_coord_correct(reg1, ao_temp.current_coord);
    current_holo_phase = f_sg_PhaseHologram2(current_coord_corr, reg1);
    ao_temp.current_holo_phase = current_holo_phase;

    %% create scan sequence
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential')
        
        if step_fac > 2
            currentZn = currentZn + 1;
            step_fac = 1;
        end
        
        if make_scan
            zernike_imn2 = zernike_imn(zernike_imn(:,2) == currentZn,:);
            num_Zm = size(zernike_imn2,1);
            %num_Zm_seq = num_Zm*num_W_step_reps;
            Zm_seq = 1:num_Zm;
            delta_i_seq = zeros(num_Zm,1);
            delta_w_seq = zeros(num_Zm,1);
            Zm_seq2 = Zm_seq(randsample(num_Zm, num_Zm));
            %Zm_seq2 = repmat(Zm_seq(randsample(num_Zm, num_Zm))', [num_W_step_reps, 1]);
            
            
            make_scan = 0;
            %currentZn = currentZn + 1;
            currentZm_seq = 1;
            zernike_imn2 = zernike_imn(zernike_imn(:,2) == currentZn,:);
            num_Zm = size(zernike_imn2,1);
            %num_Zm_seq = num_Zm*num_W_step_reps;
        end

        %zernike_imn3 = zernike_imn2(zernike_imn(:,1) == mode_seq(mode_seq_idx),:);
        zernike_imn3 = zernike_imn2(Zm_seq2(currentZm_seq), :);
        
        W_step = init_W_step/step_fac;
        weights1 = (-W_lim_steps*W_step):W_step:(W_lim_steps*W_step);
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential gradient')
        zernike_imn3 = zernike_imn(zernike_imn(:,2) == currentZn,:);
        
        W_step = init_W_step/reduce_w_step_fac;
        if grad3_weights
            weights1 = [-W_step, 0,  W_step];
        else
            weights1 = [-W_step,  W_step];
        end
    else
        % weights
        W_step = init_W_step/reduce_w_step_fac;

        if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
            zernike_imn3 = zernike_imn;
            
            weights1 = (-W_lim_steps*W_step):W_step:(W_lim_steps*W_step);
        elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Full gradient')
            zernike_imn3 = zernike_imn2;
            
            if grad3_weights
                weights1 = [-W_step, 0,  W_step];
            else
                weights1 = [-W_step,  W_step];
            end
        end
    end
    
    Zm_seq_all{n_it} = zernike_imn3;
    ao_temp.W_step = W_step;
    ao_temp.d_w_all(n_it) = W_step;
    ao_temp.weights1 = weights1;
    num_modes_scan = size(zernike_imn3,1);
    num_weights = numel(weights1);
    scan_seq1 = cat(3, repmat(zernike_imn3(:,1), [1, num_weights]), ones(num_modes_scan, num_weights).*weights1);
    scan_seq1 = permute(scan_seq1, [2, 1, 3]);
    scan_seq1 = reshape(scan_seq1, [num_modes_scan*num_weights, 2]);
    scan_seq1 = repmat(scan_seq1, [ao_params.scans_per_mode, 1]);
    grad_scan_seq = num2cell(scan_seq1, 2);

    num_scans = size(grad_scan_seq,1);
    if ao_params.shuff_scan
        scan_seq2 = scan_seq1(randsample(num_scans,num_scans),:);
    else
        scan_seq2 = scan_seq1;
    end
    
    grad_scan_seq = num2cell(scan_seq2, 2);
    
    %% scan mode sequence
    [frames, num_scans_done] = f_sg_AO_scan_ao_seq(app, ao_temp.current_AO_phase, grad_scan_seq, num_scans_done, ao_temp);
    
    %% analyze
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
        % process find best mode
        [AO_correction_new, mode_data_all{n_it}] = f_sg_AO_find_best_mode_grid(frames, grad_scan_seq, ao_params);
    else %if strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        [AO_correction_new, ao_temp, intensity_change] = f_sg_AO_analyze_scan(frames, grad_scan_seq, ao_params, ao_temp);
    end
    
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential')
        delta_i_seq(currentZm_seq) = intensity_change;
        delta_w_seq(currentZm_seq) = sum(AO_correction_new(:,2));
        currentZm_seq = currentZm_seq + 1;
        if currentZm_seq > num_Zm
            make_scan = 1;
            if mean(abs(delta_w_seq)) < (W_step/2)
                step_fac = step_fac * 2;
            end
        end
    end
    
    % update corrections
    AO_corrections_all{n_it} = AO_correction_new;
    
    %% scan all corrections
    if sum(ao_temp.init_AO_correction) == 1
        x_intens_scan = 0:n_it;
        AO_corrections_all2 = [{[1 0]}; AO_corrections_all];
        scan_pad = 1;
    else
        x_intens_scan = -1:n_it;
        AO_corrections_all2 = [{[1 0]}; {ao_temp.init_AO_correction}; AO_corrections_all];
        scan_pad = 2;
    end
        
    scan_seq = x_intens_scan' + scan_pad;
    if or((num_scans_done - num_iter_intens_scan) > ao_params.interate_intens_every, n_it == app.NumiterationsSpinner.Value)
        num_iter_intens_scan = num_scans_done;
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

    scan_seq3 = cell(num_scans_ver, 1);
    for n_seq = 1:num_scans_ver
        scan_seq3{n_seq} = cat(1,AO_corrections_all2{1:scan_seq2(n_seq)});
    end
    
    [frames, num_scans_done] = f_sg_AO_scan_ao_seq(app, zeros(reg1.SLMm, reg1.SLMn), scan_seq3, num_scans_done, ao_temp);

    intensit = zeros(num_scan_corrections,1);
    
    for n_fr = 1:num_scan_corrections
        fr_idx1 = find(scan_seq2 == (x_intens_scan2(n_fr)+scan_pad));
        for n_fr2 = 1:numel(fr_idx1)
            temp_deets = f_get_PFS_deets_fast(frames(:,:,fr_idx1(n_fr2)), [ao_params.sigma_pixels, ao_params.sigma_pixels]);
            if n_fr2 == 1
                deets_corr = temp_deets;
            else
                deets_corr(n_fr2) = temp_deets;
            end
        end
        if ao_params.intensity_use_peak
            intensit(n_fr) = deets_corr.intensity_peak;
        else
            intensit(n_fr) = deets_corr.intensity_mean_sm;
        end
    end
    
    %% update w_step
    if and(intensit(end) < intensit(end-1), sum(strcmpi(app.OptimizationmethodDropDown.Value, {'Sequential gradient', 'Full gradient'})))
        ao_temp.good_correction(n_it) = 0;
        reduce_w_step_fac = reduce_w_step_fac*2;
        AO_corrections_all(n_it) = {[]};
    end
    
    %AO_corrections_all(~good_correction) = {[]};
    
    if num_scan_corrections == (n_it+scan_pad)
        ao_temp.cent_mn = round(mean(cat(1,deets_corr.cent_mn),1));
        ao_temp.bead_im = mean(frames(:,:,fr_idx1),3);
        deeps_post{n_it} = deets_corr;
        
        ao_temp.bead_mn = ao_temp.bead_mn + round(ao_temp.cent_mn) - [ao_params.bead_im_window/2 ao_params.bead_im_window/2];

        ao_temp.im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + ao_temp.bead_mn(1));
        ao_temp.im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + ao_temp.bead_mn(2));
    end
    
    %% maybe plot
    if app.PlotprogressCheckBox.Value
        figure(ao_temp.f1);
        ao_temp.sp1{1}.Children(~ao_temp.pl_idx_line).CData = ao_temp.bead_im;
        ao_temp.sp1{1}.Children(ao_temp.pl_idx_line).XData = ao_temp.cent_mn(2);
        ao_temp.sp1{1}.Children(ao_temp.pl_idx_line).YData = ao_temp.cent_mn(1);

        subplot(ao_temp.sp1{2});
        plot(x_intens_scan2, intensit, '-o');
    end
    
    ao_data.AO_correction = AO_corrections_all;
    ao_data.good_correction = ao_temp.good_correction;
    ao_data.z_all = ao_temp.z_all;
    ao_data.step_size_all = ao_temp.step_size_all;
    ao_data.w_step_all = ao_temp.w_step_all;
    ao_data.mode_data_all = ao_temp.all_modes;
    ao_data.deeps_post = deeps_post;
    ao_data.PSF_all = PSF_all;
    ao_data.intensity_x_all{n_it} = x_intens_scan2;
    ao_data.intensity_all{n_it} = intensit;
    
    save([name_tag2 '.mat'], 'ao_data', '-v7.3');
end

%% scan PSF at end
current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all{:}), ao_temp) + ao_temp.init_AO_phase;
ao_temp.current_AO_phase = current_AO_phase;

if 0
    psf_z = -10:0.1:10;
    [ao_data.PSF_final, num_scans_done] = f_sg_AO_scan_z_defocus(app, psf_z, num_scans_done, ao_temp)
end

%%
current_coord_corr = f_sg_coord_correct(reg1, ao_temp.current_coord);
current_holo_phase = f_sg_PhaseHologram2(current_coord_corr, reg1);

complex_exp_corr = exp(1i*(current_holo_phase+current_AO_phase));
SLM_phase_corr = angle(complex_exp_corr);

if reg1.zero_outside_phase_diameter
    SLM_phase_corr(~reg1.holo_mask) = 0;
end

% apply lut and upload
init_SLM_phase_corr_lut = ao_temp.init_SLM_phase_corr_lut;
init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
ao_temp.holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, ao_temp.holo_im_pointer);

%% save

save([name_tag2 '.mat'], 'ao_data', '-v7.3');
saveas(ao_temp.f1,[name_tag2 'intensity.fig']);
saveas(ao_temp.f2,[name_tag2 'mode_weight.fig']);
%% save stuff
disp('Done');
end