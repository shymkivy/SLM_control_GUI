function num_frames = f_sg_AO_wait_for_frame_convert(path1, num_scans_done)

num_frames = 0;
% wait for frame to convert
while num_frames < num_scans_done
    files1 = dir([path1 '\' '*tif']);
    fnames = {files1.name}';
    num_frames = numel(fnames);
    pause(0.005)
end

end