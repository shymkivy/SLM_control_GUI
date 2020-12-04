function f_SLM_EOF_Zscan(app, holo_pointers, num_planes_all, imaging_button, scans_per_vol)
% end of frame scan

if ~exist('scans_per_vol', 'var') || isempty(scans_per_vol)
    scans_per_vol = 1;
end

session = app.DAQ_session;
resetCounters(session);
pause(0.05);

imaging = true;
frame_start_times = zeros(num_planes_all,1);
SLM_frame = 1;
num_planes = numel(holo_pointers);
tic;

f_SLM_BNS_update(app.SLM_ops, holo_pointers{1}); 
frame_start_times(1) = toc;

disp('Ready to start imaging');
while imaging
    scan1 = inputSingleScan(session);
    scan_frame = scan1(1)+1;
    if scan_frame > SLM_frame*scans_per_vol
        f_SLM_BNS_update(app.SLM_ops, holo_pointers{rem(scan_frame-1,num_planes)+1});
        frame_start_times(scan_frame) = toc;
        SLM_frame = round((scan_frame-1)/scans_per_vol+1);
        if scan_frame > num_planes_all
            imaging = 0;
        end
    end

    if (toc -  frame_start_times(scan_frame)) > 1
        pause(0.0001);
        if ~imaging_button.Value
            imaging = 0;
            disp('Aborted run');
        end
    end
end

resetCounters(session);
if app.PlotSLMupdateratesCheckBox.Value
    if num_planes_all>3
        figure;
        plot(diff(frame_start_times(2:end-1)));
        xlabel('frame'); ylabel('time (ms)');
        title('SLM update rate');
    end
end

%app.SLM_Image = app.SLM_blank_im;
%f_SLM_upload_image_to_SLM(app);
disp('Done');
end