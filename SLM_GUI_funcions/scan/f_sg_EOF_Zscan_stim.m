function scan_data = f_sg_EOF_Zscan_stim(app, holo_pointers, num_planes_all)
% end of frame scan with simultaneous stimulation in 2 regions of 1 SLM
% uses AI input to turn on AI patterns in real time, (3sm update time)
% assuming stim side of SLM can change without disrupting imaging side
% all patterns are precomputed

session = app.DAQ_session;
resetCounters(session);
pause(0.05);

imaging = true;
frame_start_times = zeros(num_planes_all,1);
stim_times_types = zeros(num_planes_all,2); % should not be more than num scans
SLM_frame = 1;
SLM_stim_type = 0;
n_SLM_stim = 1;
[num_planes, num_stim] = size(holo_pointers);

stim_type_ids = linspace(0, 5, num_stim);
fprintf('\nSTIM IDS (0=BLANK)\n');
for idx = 1:num_stim
    fprintf('(%s): %.3f\n', string([idx-1, stim_type_ids(idx)]));
end
tic;

scan1 = inputSingleScan(session);
stim_type = round(scan1(2)/5*(num_stim-1)); % 0 is blank, 1-N for N patterns
f_SLM_update(app.SLM_ops, holo_pointers{1,stim_type}); 
pause(0.01)
frame_start_times(1) = toc;


disp('Ready to start imaging');
while imaging
    scan1 = inputSingleScan(session);
    scan_frame = scan1(1)+1;
    stim_type = round(scan1(2)/5*(num_stim-1));
    if scan_frame > SLM_frame  % if new frame
        f_SLM_update(app.SLM_ops, holo_pointers{rem(scan_frame-1,num_planes)+1,stim_type});
        frame_start_times(scan_frame) = toc;
        if stim_type~=SLM_stim_type % or change of stim
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
        session.outputSingleScan(logical(stim_type)*5);
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
stim_times_types(~sum(stim_times_types,2),:) = [];
scan_data.frame_start_times = frame_start_times;
scan_data.stim_times_types = stim_times_types;
scan_data.holo_pointers = holo_pointers;

disp('Done');
end
