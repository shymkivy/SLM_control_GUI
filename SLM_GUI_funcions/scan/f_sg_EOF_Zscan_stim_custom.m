function scan_data = f_sg_EOF_Zscan_stim_custom(app, holo_pointers, custom_stim_data, num_planes_all)
% end of frame scan with simultaneous stimulation in 2 regions of 1 SLM
% uses AI input to turn on AI patterns in real time, (3sm update time)
% assuming stim side of SLM can change without disrupting imaging side
% all patterns are precomputed

session = app.DAQ_session;
resetCounters(session);
session.outputSingleScan(0);
session.outputSingleScan(0);
pause(0.05);

imaging = true;
frame_start_times = zeros(num_planes_all,1);
stim_times_types = zeros(num_planes_all,2); % should not be more than num scans
stim_trace = custom_stim_data.stim_trace;
len_stim_trace = numel(stim_trace);
SLM_frame = 1;
SLM_stim_type = 0;
n_SLM_stim = 1;
[num_planes, ~] = size(holo_pointers);
tic;

%scan1 = inputSingleScan(session);
%stim_type = round(scan1(2)+1);
cur_stim_time_ms = 1;
stim_type = round(stim_trace(cur_stim_time_ms) + 1);
f_SLM_update(app.SLM_ops, holo_pointers{1,stim_type}); 
pause(0.01)
frame_start_times(1) = toc;

disp('Ready to start imaging');
while imaging
    scan1 = inputSingleScan(session);
    scan_frame = scan1(1)+1;
    if frame_start_times(2)
        cur_stim_time_ms = round((toc - frame_start_times(2))*1000);
        if cur_stim_time_ms > len_stim_trace
            stim_type = 1;
        else
            stim_type = round(stim_trace(cur_stim_time_ms) + 1);
        end
    end
    %stim_type = round(scan1(2)+1);
    if scan_frame > SLM_frame  % if new frame
        f_SLM_update(app.SLM_ops, holo_pointers{rem(scan_frame-1,num_planes)+1,stim_type});
        frame_start_times(scan_frame) = toc;
        if stim_type~=SLM_stim_type % or change of stim
            session.outputSingleScan((stim_type>1)*5);
            session.outputSingleScan((stim_type>1)*5);
            SLM_stim_type = stim_type;
            stim_times_types(n_SLM_stim,1) = frame_start_times(scan_frame);
            stim_times_types(n_SLM_stim,2) = stim_type;
            n_SLM_stim = n_SLM_stim + 1;
        end
        SLM_frame = scan_frame;
        if scan_frame > num_planes_all
            imaging = 0;
        end
    elseif stim_type~=SLM_stim_type % or change of stim
        f_SLM_update(app.SLM_ops, holo_pointers{rem(scan_frame-1,num_planes)+1,stim_type});
        session.outputSingleScan((stim_type>1)*5);
        session.outputSingleScan((stim_type>1)*5);
        SLM_stim_type = stim_type;
        stim_times_types(n_SLM_stim,1) = toc;
        stim_times_types(n_SLM_stim,2) = stim_type;
        n_SLM_stim = n_SLM_stim + 1;
    end
    
    if (toc -  frame_start_times(scan_frame)) > 5
        pause(0.0001);
        if ~app.InitializeimagingButton.Value
            imaging = 0;
            disp('Aborted run');
        end
    end
end

pause(1);
resetCounters(session);
session.outputSingleScan(0);
stim_times_types(~sum(stim_times_types,2),:) = [];
scan_data.frame_start_times = frame_start_times;
scan_data.stim_times_types = stim_times_types;
scan_data.holo_pointers = holo_pointers;
scan_data.custom_stim_data = custom_stim_data;
scan_data.custom_stim_start = frame_start_times(2);

disp('Done');
end
