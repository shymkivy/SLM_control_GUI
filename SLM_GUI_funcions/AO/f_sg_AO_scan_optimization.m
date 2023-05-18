function f_sg_AO_scan_optimization(app, ao_temp_in)
disp('Starting optimization...');

load_temp = 0;
if exist('ao_temp_in', 'var')
    if ~isempty(ao_temp_in)
        load_temp = 1;
        fprintf('continuing optimizatoin\n')
    end
end
  
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
ao_params.refocus_every = app.RefocuseverynframesEditField.Value;
ao_params.refoucs_sm_spline_param = app.RefocussplinesmparamEditField.Value;
ao_params.interate_intens_every = app.ScanallcorreverynframesEditField.Value;
ao_params.scans_per_mode = app.ScanspermodeEditField.Value;
ao_params.shuff_scan = app.ShufflemodesCheckBox.Value;
ao_params.intensity_use_peak = 0;
ao_params.weight_spline_smooth = app.WsplinesmparamEditField.Value;
ao_params.reg_factor = app.WregfactorEditField.Value;

reg1 = f_sg_get_reg_deets(app, ao_params.region_name);

ao_params.region_params = reg1;
ao_params.init_coord = app.current_SLM_coord;

ao_temp.current_coord = app.current_SLM_coord;
ao_temp.init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;
ao_temp.holo_im_pointer = f_sg_initialize_pointer(app);
ao_temp.reg1 = reg1;
ao_temp.scan_path = app.ScanframesdirpathEditField.Value;


ao_params.name_tag = name_tag;

ao_temp.name_tag_full = sprintf('%s\\%s_z%d',...
            app.SLM_ops.save_AO_dir, name_tag, ao_params.init_coord.xyzp(3));

%% first upload (maybe not needed. already there)

z_comp1 = 0;
if app.ApplyAOcorrectionButton.Value
    [ao_temp.init_AO_phase, ao_temp.init_AO_correction] = f_sg_AO_get_z_corrections(app, reg1, ao_params.init_coord.xyzp(:,3));
    
    if app.CompensatezCheckBox.Value
        if isfield(reg1.AO_wf, 'fit_defocus_comp')
            if strcmpi(class(reg1.AO_wf.fit_defocus_comp),'cfit')
                z_comp1 = reg1.AO_wf.fit_defocus_comp(ao_temp.current_coord.xyzp(3));
            end
        end
    end
else
    ao_temp.init_AO_correction = [1, 0];
    ao_temp.init_AO_phase = zeros(reg1.SLMm, reg1.SLMn);
end

ao_temp.current_coord.xyzp(3) = ao_temp.current_coord.xyzp(3) + z_comp1;
num_iter = app.NumiterationsSpinner.Value;
if load_temp
    if ao_temp_in.n_it < num_iter
        ao_temp.current_coord = ao_temp_in.current_coord;
    end
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

max_modes_init = max(ao_temp.init_AO_correction(:,1));
maxZn_init = ceil((-1 + sqrt(1 + 4*max_modes_init*2))/2)-1;

max_Zn = app.MaxZnEditField.Value;
min_Zn = app.MinZnEditField.Value;
zernike_nm_all = f_sg_get_zernike_mode_nm(0:max([maxZn_init, max_Zn]));
num_modes_all = size(zernike_nm_all ,1);
% generate all polynomials
all_modes_phase = f_sg_gen_zernike_modes(reg1, zernike_nm_all);
ao_temp.all_modes = all_modes_phase;

zernike_imn = f_sg_AO_get_zernike_imn(min_Zn:max_Zn);

ao_temp.zernike_nm_all = zernike_nm_all;

%% plot correction potential per mode
dims = size(init_holo_phase);
ph_d = reg1.phase_diameter;
Lx = linspace(-dims(2)/ph_d, dims(2)/ph_d, dims(2));
Ly = linspace(-dims(1)/ph_d, dims(1)/ph_d, dims(1));
sigma = 1;

%Lx = linspace(-(siz-1)/2,(siz-1)/2,siz);
%sigma = reg1.beam_diameter/2; 			% beam waist/2

[c_X, c_Y] = meshgrid(Lx, Ly);
x0 = 0;                 % beam center location
y0 = 0;                 % beam center location
A = 1;                  % peak of the beam 
res = ((c_X-x0).^2 + (c_Y-y0).^2)./(2*sigma^2);
pupil_amp = A  * exp(-res);

weight_pt = squeeze(sum(sum(pupil_amp.*abs(all_modes_phase(:,:,4:end)),1),2));

figure;
plot(4:(numel(weight_pt)+3),weight_pt/max(weight_pt))
title('Correction potential per mode');
xlabel('mode index');
%%
resetCounters(app.DAQ_session);
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);

[num_scans_done,ao_temp, ao_params] = f_sg_AO_init_xy_align(app, ao_temp, ao_params);

%% scan

center_defocus_z_range = linspace(-app.RefocusdistumEditField.Value/2, app.RefocusdistumEditField.Value/2, app.RefocusnumstepsEditField.Value);

W_range = app.WeightrangeEditField.Value;
W_num_steps = app.NumwstepsEditField.Value;
init_W_step = W_range*2/(W_num_steps-1);
W_step = init_W_step;
%W_lim_steps = app.WeightlimitEditField.Value/W_step;
W_step_thresh = 0.05;

ao_params.W_step = W_step;
ao_params.W_num_steps = W_num_steps;
ao_params.step_size = 10/num_modes_all;
ao_params.ma_num_it = 2;

ao_temp.mode_data_all = cell(app.NumiterationsSpinner.Value,1);
ao_temp.deeps_post = cell(app.NumiterationsSpinner.Value,1);
ao_temp.PSF_all = cell(num_iter, 1);
ao_temp.bead_im_all = cell(num_iter,1);
ao_temp.z_all = zeros(num_iter, 1);
ao_temp.z_all_idx = false(num_iter, 1);

currentZn = min(zernike_imn(:,2));
currentZm_seq = 1;
Zm_seq_all = cell(num_iter,1);
grad3_weights = 1;

ao_temp.step_size_all = zeros(num_iter, 1);
ao_temp.w_step_all = zeros(num_iter, num_modes_all);
ao_temp.d_w_all = zeros(num_iter, 1);
ao_temp.intensity_x_all = cell(num_iter,1);
ao_temp.intensity_all = cell(num_iter,1);
ao_temp.iter_filled = false(num_iter,1);

ao_temp.AO_corrections_all = cell(num_iter, 1);
ao_temp.good_correction = false(num_iter, 1);

num_refocus_scan = num_scans_done - ao_params.refocus_every - 1; % to do it on first iteration
num_corr_scan = num_scans_done - ao_params.refocus_every -1;

step_max = 2^(app.DecresegradntimesEditField.Value);
make_scan = 1;
step_fac = 1;
ao_data.ao_params = ao_params;
ao_data.all_modes_phase = all_modes_phase;
ao_data.init_AO_correction = ao_temp.init_AO_correction;

continue_scan = 1;

n_it = 1;

if load_temp
    if ao_temp_in.n_it < num_iter
        n_it = ao_temp_in.n_it;
        ao_temp.iter_filled(1:n_it) =           ao_temp_in.iter_filled(1:n_it);
        ao_temp.AO_corrections_all(1:n_it) =    ao_temp_in.AO_corrections_all(1:n_it);
        ao_temp.good_correction(1:n_it) =       ao_temp_in.good_correction(1:n_it);
        ao_temp.z_all(1:n_it) =                 ao_temp_in.z_all(1:n_it);
        ao_temp.z_all_idx(1:n_it) =             ao_temp_in.z_all_idx(1:n_it);
        ao_temp.step_size_all(1:n_it) =         ao_temp_in.step_size_all(1:n_it);
        ao_temp.w_step_all(1:n_it) =            ao_temp_in.w_step_all(1:n_it);
        ao_temp.d_w_all(1:n_it) =               ao_temp_in.d_w_all(1:n_it);
        ao_temp.deeps_post(1:n_it) =            ao_temp_in.deeps_post(1:n_it);
        ao_temp.bead_im_all(1:n_it) =           ao_temp_in.bead_im_all(1:n_it);
        ao_temp.PSF_all(1:n_it) =               ao_temp_in.PSF_all(1:n_it);
        ao_temp.intensity_x_all(1:n_it) =       ao_temp_in.intensity_x_all(1:n_it);
        ao_temp.intensity_all(1:n_it) =         ao_temp_in.intensity_all(1:n_it);
        ao_temp.mode_data_all(1:n_it) =         ao_temp_in.mode_data_all(1:n_it);

        ao_temp.name_tag_full =                 ao_temp_in.name_tag_full;
    else
        fprintf('Not enough iterations set, restarting fresh\n');
    end
end

while and(and(n_it <= num_iter, currentZn <= max_Zn), continue_scan)
    fprintf('Iteration %d/%d; scan %d...\n', n_it, num_iter, num_scans_done);
    ao_temp.n_it = n_it;
    ao_temp.good_correction(n_it) = 1;

    %% update AO phase
    AO_corrections_all2 = [{ao_temp.init_AO_correction}; ao_temp.AO_corrections_all];
    %current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all{:}), ao_temp) + ao_temp.init_AO_phase;
    current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_corrections_all2{:}), ao_temp);
    ao_temp.current_AO_phase = current_AO_phase;
    
    %% refocus in z
    if (num_scans_done - num_refocus_scan) > ao_params.refocus_every
        [current_coord, num_scans_done, ao_temp.PSF_all{n_it}] = f_sg_AO_refocus_PSF(app, center_defocus_z_range, num_scans_done, ao_temp, ao_params);
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
        
        fprintf('Seq scan; Zn = %d/%d; idx = %d; Zm = %d; %d/%d; grad fac = %d\n', currentZn,max_Zn, zernike_imn3(1), zernike_imn3(3), currentZm_seq, num_Zm, step_fac);
        
        weights1 = linspace(-W_range, W_range, W_num_steps)/step_fac;

    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential gradient')
        zernike_imn3 = zernike_imn(zernike_imn(:,2) == currentZn,:);
        
        W_step = init_W_step/step_fac;
        if grad3_weights
            weights1 = [-W_step, 0,  W_step];
        else
            weights1 = [-W_step,  W_step];
        end
    else
        % weights
        W_step = init_W_step/step_fac;

        if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
            zernike_imn3 = zernike_imn;
            
            weights1 = linspace(-W_range, W_range, W_num_steps);

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
    ao_temp.W_step = init_W_step/step_fac;
    ao_temp.d_w_all(n_it) = init_W_step/step_fac;
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
        [AO_correction_new, ao_temp.mode_data_all{n_it}] = f_sg_AO_find_best_mode_grid(frames, grad_scan_seq, ao_params);
    else %if strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        [AO_correction_new, ao_temp, intensity_change] = f_sg_AO_analyze_scan(frames, grad_scan_seq, ao_params, ao_temp);
    end
    
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Sequential')
        delta_i_seq(currentZm_seq) = intensity_change;
        delta_w_seq(currentZm_seq) = sum(AO_correction_new(:,2));
        currentZm_seq = currentZm_seq + 1;
        if currentZm_seq > num_Zm
            make_scan = 1;
            if mean(abs(delta_w_seq)) < (W_step)
                step_fac = step_fac * 2;
            end
        end
    end
    
    % update corrections
    ao_temp.AO_corrections_all{n_it} = AO_correction_new;
    
    %% scan all corrections
    fprintf('Scanning corrections\n')
    
    if sum(ao_temp.init_AO_correction) == 1
        x_intens_scan = 0:n_it;
        AO_corrections_all2 = [{[1 0]}; ao_temp.AO_corrections_all];
        scan_pad = 1;
    else
        x_intens_scan = -1:n_it;
        AO_corrections_all2 = [{[1 0]}; {ao_temp.init_AO_correction}; ao_temp.AO_corrections_all];
        scan_pad = 2;
    end
    
    num_corr_scan2 = num_scans_done;
    scan_seq = x_intens_scan' + scan_pad;
    if or((num_scans_done - num_corr_scan) > ao_params.interate_intens_every, n_it == app.NumiterationsSpinner.Value)
        num_corr_scan = num_scans_done;
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
    
    % to ignore correction scans in 
    num_corr_scan = num_corr_scan + num_scans_done - num_corr_scan2;
    
    % calculate intensity changes
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
        step_fac = step_fac*2;
        ao_temp.AO_corrections_all(n_it) = {[]};
    end
    
    if step_fac > step_max
        currentZn = currentZn + 1;
        step_fac = 1;
    end
    
    %AO_corrections_all(~good_correction) = {[]};
    
    %if num_scan_corrections == (n_it+scan_pad)
    ao_temp.cent_mn = round(mean(cat(1,deets_corr.cent_mn),1));
    ao_temp.bead_im = mean(frames(:,:,fr_idx1),3);
    ao_temp.deeps_post{n_it} = deets_corr;
    ao_temp.bead_im_all{n_it} = ao_temp.bead_im;

    ao_temp.bead_mn = ao_temp.bead_mn + round(ao_temp.cent_mn) - [ao_params.bead_im_window/2 ao_params.bead_im_window/2];
    ao_temp.im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + ao_temp.bead_mn(1));
    ao_temp.im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + ao_temp.bead_mn(2));
    
    if or(ao_temp.im_m_idx < 1, ao_temp.im_n_idx < 1)
        continue_scan = 0;
    end
    if or(ao_temp.im_m_idx > 256, ao_temp.im_n_idx > 256)
        continue_scan = 0;
    end
    
    if ~app.StartoptimizationButton.Value
        continue_scan = 0;
        fprintf('Finishing scan early\n')
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

    %%
    ao_temp.intensity_x_all{n_it} = x_intens_scan2;
    ao_temp.intensity_all{n_it} = intensit;
    
    ao_temp.iter_filled(n_it) = 1;
    n_it = n_it + 1;
    
    %%
    ao_data.AO_correction =     ao_temp.AO_corrections_all(ao_temp.iter_filled);
    ao_data.good_correction =   ao_temp.good_correction(ao_temp.iter_filled);
    ao_data.z_all =             ao_temp.z_all(ao_temp.iter_filled);
    ao_data.z_all_idx =         ao_temp.z_all_idx(ao_temp.iter_filled);
    ao_data.step_size_all =     ao_temp.step_size_all(ao_temp.iter_filled);
    ao_data.w_step_all =        ao_temp.w_step_all(ao_temp.iter_filled,:);
    ao_data.d_w_all =           ao_temp.d_w_all(ao_temp.iter_filled);
    ao_data.deeps_post =        ao_temp.deeps_post(ao_temp.iter_filled);
    ao_data.bead_im_all =       ao_temp.bead_im_all(ao_temp.iter_filled);
    ao_data.PSF_all =           ao_temp.PSF_all(ao_temp.iter_filled);
    ao_data.intensity_x_all =   ao_temp.intensity_x_all(ao_temp.iter_filled);
    ao_data.intensity_all =     ao_temp.intensity_all(ao_temp.iter_filled);
    ao_data.mode_data_all =     ao_temp.mode_data_all(ao_temp.iter_filled);
    
    app.GUI_buffer.ao_temp = ao_temp;
    
    save([ao_temp.name_tag_full '.mat'], 'ao_data', '-v7.3');
end

%% scan PSF at end
current_AO_phase = f_sg_AO_corr_to_phase(cat(1,ao_temp.AO_corrections_all{:}), ao_temp) + ao_temp.init_AO_phase;
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
core_init = f_sg_AO_condense_corr(ao_temp.init_AO_correction);

corr_final2 = [ao_temp.init_AO_correction; ao_temp.AO_corrections_all];
corr_final = f_sg_AO_condense_corr(cat(1,corr_final2{:}));

f3 = figure; 
subplot(2,1,1); hold on;
plot(core_init(:,1), core_init(:,2), '-o')
plot(corr_final(:,1), corr_final(:,2), '-o')
ylabel('weight');
legend('initial', 'fina');
subplot(2,1,2); hold on;
plot(corr_final(:,1), corr_final(:,2) - core_init(:,2), '-o')
title('difference');
xlabel('modes');
ylabel('weight change');
sgtitle([name_tag ' weight changes'], 'interpreter', 'none')

save([ao_temp.name_tag_full '.mat'], 'ao_data', '-v7.3');
saveas(ao_temp.f1,[ao_temp.name_tag_full 'intensity.fig']);
saveas(ao_temp.f2,[ao_temp.name_tag_full 'mode_weight.fig']);
saveas(f3,[ao_temp.name_tag_full 'weight_change.fig']);
%% save stuff
disp('Done');
end