function f_SLM_scan_triggered_frame(session)

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
while trig_num2 <= trig_num
    scan1 = inputSingleScan(session);
    trig_num2 = scan1(1);
    pause(0.001);
end

%prairie needs delay to get ready for triggered frame
pause(0.5);

end