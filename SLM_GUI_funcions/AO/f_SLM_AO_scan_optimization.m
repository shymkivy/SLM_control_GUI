function f_SLM_AO_scan_optimization(app)
disp('Starting optimization...');

%%
bead_im_window = 20;
n_corrections_to_use = 1;

an_params.plot_stuff = 0;

sigma_pixels = 1;
kernel_half_size = ceil(sqrt(-log(0.1)*2*sigma_pixels^2));
[X_gaus,Y_gaus] = meshgrid((-kernel_half_size):kernel_half_size);
conv_kernel = exp(-(X_gaus.^2 + Y_gaus.^2)/(2*sigma_pixels^2));
conv_kernel = conv_kernel/sum(conv_kernel(:));

an_params.conv_kernel = conv_kernel;

%%
[m_idx, n_idx, ~,  reg1] = f_SLM_get_reg_deets(app, app.AOregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);
beam_width = app.BeamdiameterpixEditField.Value;
xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol( fX, fY );

%% initial AO_wf
AO_wf = [];
AO_correction = [];
AO_params = struct;
AO_params.AO_iteration = 1;
if app.ApplyAOcorrectionButton.Value
    reg1.AO_correction = app.AOcorrectionDropDown_2.Value;
    [AO_wf, AO_params] = f_SLM_AO_compute_wf(app, reg1);
    AO_correction = AO_params.AO_correction;
end

%%
init_image = app.SLM_Image;
SLM_image = f_SLM_AO_add_correction(app, app.SLM_Image, AO_wf);
app.SLM_Image_pointer.Value = f_SLM_im_to_pointer(SLM_image);
f_SLM_BNS_update(app.SLM_ops, app.SLM_Image_pointer);

%%


% create patterns
zernike_table = app.ZernikeListTable.Data;

% generate all polynomials
num_modes = size(zernike_table,1);
all_modes = zeros(SLMm, SLMn, num_modes);
for n_mode = 1:num_modes
    Z_nm = f_SLM_zernike_pol(rho, theta, zernike_table(n_mode,2), zernike_table(n_mode,3));
    if app.AOzerooutsideunitcircCheckBox.Value
        Z_nm(rho>1) = 0;
    end
    all_modes(:,:,n_mode) = Z_nm;
end

% generate scan sequence
all_patterns = cell(num_modes,1);
for n_mode = 1:num_modes
    if zernike_table(n_mode,7)
        weights1 = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
        temp_patterns = [ones(numel(weights1),1)*zernike_table(n_mode,1), weights1']; 
        if app.InsertrefimageinscansCheckBox.Value
            all_patterns{n_mode} = [999,999; temp_patterns];
        else
            all_patterns{n_mode} = temp_patterns;
        end
    end
end

%
zernike_scan_sequence = cat(1,all_patterns{:});
zernike_scan_sequence = repmat(zernike_scan_sequence,app.ScanspermodeEditField.Value,1);
num_scans = size(zernike_scan_sequence,1);

%%
%%
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);

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

an_params.intensity_win = ceil((deets_pre.X_fwhm + deets_pre.Y_fwhm)/4);
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
resetCounters(app.DAQ_session);
pause(0.01);

current_AO_wf = AO_wf;

holo_im_pointer = f_SLM_initialize_pointer(app);
for n_it = 1:app.NumiterationsSpinner.Value
    % add current wavefront correction
    current_im = init_image;
    if ~isempty(current_AO_wf)
        current_im(m_idx,n_idx) = angle(exp(1i*(current_im(m_idx,n_idx) + current_AO_wf))) + pi;
    end
    
    if app.ShufflemodesCheckBox.Value
        zernike_scan_sequence2 = zernike_scan_sequence(randsample(num_scans,num_scans),:);
    else
        zernike_scan_sequence2 = zernike_scan_sequence;
    end
    
    fprintf('Iteration %d...\n', n_it);
    
    for n_scan = 1:num_scans
        scan1 = inputSingleScan(app.DAQ_session);
        trig_num = scan1(1);
        %% add zernike pol on top of image
        n_mode = zernike_scan_sequence2(n_scan,1);
        n_weight = zernike_scan_sequence2(n_scan,2);
        if n_mode == 999
            holo_im = app.SLM_ref_im;
        else
            holo_im = current_im;
            holo_im(m_idx,n_idx) = angle(exp(1i*(current_im(m_idx,n_idx) + all_modes(:,:,n_mode)*n_weight))) + pi;
        end
        holo_im_pointer.Value = f_SLM_im_to_pointer(holo_im);
        
        %%
        f_SLM_BNS_update(app.SLM_ops, holo_im_pointer)
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
    
    [best_mode_list, best_mode_w_list] = f_AO_analyze_zernike(frames2, zernike_scan_sequence2, an_params);
    
    AO_correction = [AO_correction; best_mode_list(1:n_corrections_to_use)', best_mode_w_list(1:n_corrections_to_use)'];
    
    %% make new wf
    current_AO_wf = zeros(SLMm, SLMn);
    for n_mode = 1:size(AO_correction,1)
        current_AO_wf = current_AO_wf + all_modes(:,:,AO_correction(n_mode, 1))*AO_correction(n_mode, 2);
    end
    
    %%
    current_im = init_image;
    if ~isempty(current_AO_wf)
        current_im(m_idx,n_idx) = angle(exp(1i*(current_im(m_idx,n_idx) + current_AO_wf))) + pi;
    end
    holo_im_pointer.Value = f_SLM_im_to_pointer(current_im);
    
    f_SLM_BNS_update(app.SLM_ops, holo_im_pointer)
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
    
    % wait for frame to convert
    while ~num_frames
        files1 = dir([path1 '\' '*tif']);
        fnames = {files1.name}';
        num_frames = numel(fnames);
        pause(0.005)
    end

    frames = f_AO_op_get_all_frames(path1);
    num_frames = size(frames,3);
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