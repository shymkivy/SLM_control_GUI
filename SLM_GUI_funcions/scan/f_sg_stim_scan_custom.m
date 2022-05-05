function scan_data = f_sg_stim_scan_custom(app, holo_pointers, custom_stim_data, imaging_button)
% end of frame scan with simultaneous stimulation in 2 regions of 1 SLM
% uses AI input to turn on AI patterns in real time, (3sm update time)
% assuming stim side of SLM can change without disrupting imaging side
% all patterns are precomputed

scan_data.holo_pointers = holo_pointers;

session = app.DAQ_session;
if ~numel(session.Channels)
    disp('No daq channels were initiated');
    has_daq = 0;
else
    has_daq = 1;
end
if has_daq
    resetCounters(session);
    session.outputSingleScan(0);
    session.outputSingleScan(0);
    pause(0.05);
end

imaging = true;
block_size = 1e3;
stim_times_types = zeros(block_size,2); % should not be more than num scans 
stim_times_types_all = {};
stim_trace = custom_stim_data.stim_trace;
len_stim_trace = numel(stim_trace);
scan_frame = 1;
SLM_stim_type = 1;
n_SLM_stim = 1;

%scan1 = inputSingleScan(session);
%stim_type = round(scan1(2)+1);

f_SLM_update(app.SLM_ops, holo_pointers{scan_frame,SLM_stim_type}); 
pause(0.01)

cont1 = input('Ready to start custom stim scan; Press [y] to start:', 's');
if strcmpi(cont1 , 'y')
    tic;
    disp('Running...');
    while imaging
        cur_stim_time_ms = round(toc*1000+1);
        if cur_stim_time_ms > len_stim_trace
            stim_type = 1;
        else
            stim_type = round(stim_trace(cur_stim_time_ms) + 1);
        end

        if stim_type~=SLM_stim_type % or change of stim
            f_SLM_update(app.SLM_ops, holo_pointers{scan_frame,stim_type});
            if has_daq
                session.outputSingleScan((stim_type>1)*5);
                session.outputSingleScan((stim_type>1)*5);
            end
            SLM_stim_type = stim_type;
            stim_times_types(n_SLM_stim,1) = toc;
            stim_times_types(n_SLM_stim,2) = stim_type;
            fprintf('Stim %d; %.0fms\n', stim_type, stim_times_types(n_SLM_stim,1)*1000);
            n_SLM_stim = n_SLM_stim + 1;
        end
        
        if n_SLM_stim > block_size
            n_SLM_stim = 1;
            stim_times_types_all = [stim_times_types_all; stim_times_types];
            stim_times_types = zeros(block_size,2);
        end
        
        if (toc -  stim_times_types(n_SLM_stim,1)) > 10
            pause(0.0001);
            if ~imaging_button.Value
                imaging = 0;
                disp('Aborted run');
            end
        end
    end

    pause(.5);
    if has_daq
        resetCounters(session);
        session.outputSingleScan(0);
    end
    stim_times_types = cat(1,stim_times_types_all{:});
    stim_times_types(~sum(stim_times_types,2),:) = [];
    scan_data.stim_times_types = stim_times_types;
    scan_data.holo_pointers = holo_pointers;
    scan_data.custom_stim_data = custom_stim_data;

    disp('Done');
else
    disp('Run aborted');
end

end
