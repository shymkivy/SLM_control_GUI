function f_SLM_EOF_scan(app, holo_pointers, num_planes_all)


session = app.DAQ_session;
resetCounters(session);
pause(0.05);

imaging = true;
frame_start_times = zeros(num_planes_all,1);
SLM_frame = 1;
num_planes = numel(holo_pointers);
tic;

f_SLM_update_YS(app.SLM_ops, holo_pointers{1}); 
frame_start_times(1) = toc;

disp('Ready');
while imaging
    scan_frame = inputSingleScan(session)+1;
    if scan_frame > SLM_frame
        f_SLM_update_YS(app.SLM_ops, holo_pointers{rem(scan_frame-1,num_planes)+1});
        frame_start_times(scan_frame) = toc;
        SLM_frame = scan_frame;
        if scan_frame > num_planes_all
            imaging = 0;
        end
    end

    if (toc -  frame_start_times(scan_frame)) > 1
        pause(0.0001);
        if app.AbortImagingButton.Value
            imaging = 0;
        end
    end
end

resetCounters(session);
if num_planes_all>3
    figure;
    plot(diff(frame_start_times(2:end-1)));
    xlabel('frame'); ylabel('time (ms)');
end

f_SLM_update_YS(app.SLM_ops, app.SLM_blank_pointer);

end