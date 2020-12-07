function f_SLM_AO_start_optimization(app)

path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
exist(path1, 'dir')

% trigger one frame
app.DAQ_session.outputSingleScan(5);
pause(0.001);
app.DAQ_session.outputSingleScan(0);

frames = f_AO_op_get_frame(path1);
num_frames = size(frames,3);

f1 = figure; axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
[x,y] = ginput(1);
close(f1);


app.DAQ_session.outputSingleScan(5);




scan1 = inputSingleScan(app.DAQ_session);
scan_frame = scan1(1)+1
end