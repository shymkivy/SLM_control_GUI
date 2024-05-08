function scan_data = f_sg_stim_scan(app, holo_pointers)
% end of frame scan with simultaneous stimulation in 2 regions of 1 SLM
% uses AI input to turn on AI patterns in real time, (3sm update time)
% assuming stim side of SLM can change without disrupting imaging side
% all patterns are precomputed

scan_data.holo_pointers = holo_pointers;

session = app.DAQ_session;
resetCounters(session);
pause(0.05);

imaging = true;
block_size = 1e3;
stim_times_types = zeros(block_size,2); % should not be more than num scans 
stim_times_types_all = {};
scan_frame = 1;
SLM_stim_type = 1;
n_SLM_stim = 1;


f_SLM_update(app.SLM_ops, holo_pointers{1,SLM_stim_type}); 
pause(0.01)

cont1 = input('Ready to start stim scan with AI input; Press [y] to start:', 's');
if strcmpi(cont1 , 'y')
    tic;
    while imaging
        scan1 = inputSingleScan(session);
        stim_type = round(scan1(2)+1);

        if stim_type~=SLM_stim_type % or change of stim
            f_SLM_update(app.SLM_ops, holo_pointers{scan_frame,stim_type});
            session.outputSingleScan(logical(stim_type)*5);
            SLM_stim_type = stim_type;
            stim_times_types(n_SLM_stim,1) = toc;
            stim_times_types(n_SLM_stim,2) = stim_type;
            n_SLM_stim = n_SLM_stim + 1;
        end

        if n_SLM_stim > block_size
            n_SLM_stim = 1;
            stim_times_types_all = [stim_times_types_all; stim_times_types];
            stim_times_types = zeros(block_size,2);
        end

        if (toc -  stim_times_types(n_SLM_stim,1)) > 10
            pause(0.0001);
            if ~app.InitializeimagingButton.Value
                imaging = 0;
                disp('Aborted run');
            end
        end
    end

    pause(1);
    resetCounters(session);

    stim_times_types = cat(1,stim_times_types_all{:});
    stim_times_types(~sum(stim_times_types,2),:) = [];
    scan_data.stim_times_types = stim_times_types;

    disp('Done');
else
    disp('Run aborted');
end
end