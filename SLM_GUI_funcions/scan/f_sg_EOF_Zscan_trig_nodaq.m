function scan_data  = f_sg_EOF_Zscan_trig_nodaq(app, holo_pointers, num_planes_all, imaging_button, scans_per_frame)
% end of frame scan, triggers sent to SLM
% SLM needs end of frame trigger going down, to start pattern change
% counter channel needs e

if ~exist('scans_per_vol', 'var') || isempty(scans_per_frame)
    scans_per_frame = 1;
end

pause(0.05);

if scans_per_frame > 1
    holo_pointers2 = cell(scans_per_frame, size(holo_pointers,1));
    for n_scan = 1:scans_per_frame
        holo_pointers2(n_scan,:) = holo_pointers;
    end
    holo_pointers3 = holo_pointers2(:);
    num_planes_all = num_planes_all * scans_per_frame;
else
    holo_pointers3 = holo_pointers;
end

imaging = true;
frame_end_times = zeros(num_planes_all,1);

num_planes = numel(holo_pointers3);
tic;

scan_ops = app.SLM_ops;
scan_ops.wait_For_Trigger = 0;
% upload first frame no trigger
f_SLM_update(scan_ops, holo_pointers3{1});

% set second frame on the bench waiting for EOF trig
scan_ops.wait_For_Trigger = 1;
scan_ops.external_Pulse = 1;
SLM_frame = 2; % current SLM on bench
f_SLM_update(scan_ops, holo_pointers3{SLM_frame});
scan_frame = 1; % current scan frame

disp('Ready to start imaging');
last_time = toc;
while imaging

    % waits for write zero means it was success
    write_complete = f_SLM_BNS1920_write_complete(scan_ops);
    if write_complete
        % load the next frame, which is SLM_frame+1
        scan_frame = scan_frame + 1;
        SLM_frame = SLM_frame + 1;
        f_SLM_update(scan_ops, holo_pointers3{rem(SLM_frame-1,num_planes)+1});
        frame_end_times(scan_frame-1) = toc;
        last_time = frame_end_times(scan_frame-1);
    end

    if scan_frame > num_planes_all
        imaging = 0;
    end

    if (toc - last_time) > 1
        pause(0.0001);
        if ~imaging_button.Value
            imaging = 0;
            disp('Aborted run');
        end
    end
end

pause(1);
scan_data.frame_start_times = frame_end_times;
scan_data.holo_pointers = holo_pointers;
scan_data.scans_per_frame = scans_per_frame;
scan_data.num_planes_all = num_planes_all;

disp('Done');
end