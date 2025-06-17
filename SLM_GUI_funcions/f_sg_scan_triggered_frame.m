function f_sg_scan_triggered_frame(session, delay, use_counter)

if use_counter
    max_delay = 3; % in sec
    
    scan1 = inputSingleScan(session);
    trig_num = scan1(1);
    
    % send trigger
    session.outputSingleScan(5);
    session.outputSingleScan(5);
    pause(0.002);
    session.outputSingleScan(0);
    session.outputSingleScan(0);
    
    % wait for scan to end
    scan1 = inputSingleScan(session);
    trig_num2 = scan1(1);
    tic;
    while trig_num2 <= trig_num
        scan1 = inputSingleScan(session);
        trig_num2 = scan1(1);
        pause(0.001);
        % to prevent getting stuck when microscope misses trigger
        if toc > max_delay
            disp('maybe missed trigger, sending another, can increase "post scan delay"')
            % send trigger
            session.outputSingleScan(5);
            session.outputSingleScan(5);
            pause(0.002);
            session.outputSingleScan(0);
            session.outputSingleScan(0);
            tic;
        end
    end
else
    % send trigger
    session.outputSingleScan(5);
    session.outputSingleScan(5);
    pause(0.002);
    session.outputSingleScan(0);
    session.outputSingleScan(0);
end
%prairie needs delay to get ready for triggered frame
pause(delay);

end