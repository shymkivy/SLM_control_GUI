function f_SLM_AO_scan_optimization(app)

%%
intensity_win = 20;

sigma_pixels = 1;
kernel_half_size = ceil(sqrt(-log(0.1)*2*sigma_pixels^2));
[X_gaus,Y_gaus] = meshgrid((-kernel_half_size):kernel_half_size);
conv_kernel = exp(-(X_gaus.^2 + Y_gaus.^2)/(2*sigma_pixels^2));
conv_kernel = conv_kernel/sum(conv_kernel(:));

%%

AO_params = struct;
AO_params.AO_iteration = 1;
if app.ApplyAOcorrectionButton.Value
    reg1.AO_correction = app.AOcorrectionDropDown_2.Value;
    [AO_wf, AO_params] = f_SLM_AO_compute_wf(app, reg1);
end


[holo_pointers, zernike_scan_sequence] = f_SLM_AO_make_zernike_pointers(app, AO_wf);
num_scans = size(zernike_scan_sequence,1);

%path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
path1 = app.ScanframesdirpathEditField.Value;
exist(path1, 'dir');

% trigger first frame
app.DAQ_session.outputSingleScan(5);
pause(0.001);
app.DAQ_session.outputSingleScan(0);

frames = f_AO_op_get_all_frames(path1);
num_frames = size(frames,3);

f1 = figure; axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
bead_mn = zeros(1,2);
[bead_mn(2),bead_mn(1)] = ginput(1);
close(f1);
bead_mn = round(bead_mn);

%%
im_m_idx = (-intensity_win:intensity_win) + bead_mn(1);
im_n_idx = (-intensity_win:intensity_win) + bead_mn(2);

im_cut = frames(im_m_idx, im_n_idx,num_frames);

deets_pre = f_get_PFS_deets_fast(im_cut, conv_kernel, intensity_win);

%%
if app.PlotprogressCheckBox.Value
    f1 = figure; 
    sp1 = subplot(1,2,1); hold on; axis tight equal;
    imagesc(im_cut);
    plot(deets_pre.cent_mn(2),deets_pre.cent_mn(1), 'ro');
    sp2 = subplot(1,2,2); axis tight;
    plot(0, deets_pre.intensity_raw);
    
    pl_idx_line = isprop(sp1.Children, 'LineStyle');
end

%% scan

init_image = app.SLM_Image;

deets_all = cell(app.NumiterationsSpinner.Value, num_scans);

resetCounters(app.DAQ_session);
pause(0.01);

AO_wf_now = AO_wf;
for n_it = 1:app.NumiterationsSpinner.Value
    [holo_pointers, ~] = f_SLM_AO_make_zernike_pointers(app, AO_wf_now);
    for n_scan = 1:num_scans
        scan1 = inputSingleScan(app.DAQ_session);
        trig_num = scan1(1)+1;
        %%
        f_SLM_BNS_update(app.SLM_ops, holo_pointers{n_scan})
        
        % send trigger
        app.DAQ_session.outputSingleScan(5);
        pause(0.001);
        app.DAQ_session.outputSingleScan(0);
        
        % wait for scan to end
        scan1 = inputSingleScan(app.DAQ_session);
        trig_num2 = scan1(1)+1;
        while trig_num2 <= trig_num
            scan1 = inputSingleScan(app.DAQ_session);
            trig_num2 = scan1(1)+1;
            pause(0.001);
        end
        
        [last_frame, num_frame] = f_AO_op_get_last_frame(path1);
        
        deets_all{n_it, n_scan} = f_get_PFS_deets_fast(last_frame(im_m_idx, im_n_idx), conv_kernel, intensity_win);
        deets_all{n_it, n_scan}.num_frame = num_frame;
    end
    
    %% find best mode and weight
    
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