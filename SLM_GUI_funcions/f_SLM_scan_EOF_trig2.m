function scan_data = f_SLM_scan_EOF_trig2(app, holo_pointers, holo_patterns_ai, reg_idx_ai, num_planes_all, imaging_button)

session = app.DAQ_session;
resetCounters(session);
pause(0.05);

imaging = true;
frame_start_times = zeros(num_planes_all,1);
SLM_frame = 1;
num_planes = numel(holo_pointers);
tic;

f_SLM_BNS_update(app.SLM_ops, holo_pointers{1});
pause(0.01);
frame_start_times(1) = toc;

disp('Ready to start imaging');
while imaging
    scan1 = inputSingleScan(session);
    scan_frame = scan1(1)+1;
    ai_input = session.inputSingleScan;
    if scan_frame > SLM_frame
        f_SLM_BNS_update(app.SLM_ops, holo_pointers{rem(scan_frame-1,num_planes)+1});
        frame_start_times(scan_frame) = toc;
        SLM_frame = scan_frame;
        if scan_frame > num_planes_all
            imaging = 0;
        end
    end
    
    if (toc -  frame_start_times(scan_frame)) > 5
        pause(0.0001);
        if ~imaging_button.Value
            imaging = 0;
            disp('Aborted run');
        end
    end
end

pause(1);
resetCounters(session);
scan_data.frame_start_times = frame_start_times;

disp('Done');
end