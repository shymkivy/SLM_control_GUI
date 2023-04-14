function all_frames = f_sg_AO_get_all_frames(path1)

files1 = dir([path1 '\' '*tif']);

fnames = {files1.name}';
num_frames = numel(fnames)-1;
all_frames = zeros(256,256,num_frames);
for n_fr = 1:num_frames
    all_frames(:,:,n_fr) = imread([path1 '\' fnames{n_fr}]);  
%     fileID = Tiff([path1 '\' fnames{1}],'r');
%     all_frames(:,:,n_fr) = read(fileID);
%     close(fileID);
end

% 
% path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-003';
% %path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\scan-003';
% exist(path1, 'dir')
% files1 = dir([path1 '\' '*RAWDATA*']);
% fnames = {files1.name}';
% precis = 'uint32';
% fileID = fopen([path1 '\' fnames{1}],'r');
% num_frames = 0;
% I=fread(fileID, 256*256, precis);
% while ~isempty(I)
%     I=fread(fileID, 256*256, precis);
%     num_frames = num_frames + 1;
% end
% fclose(fileID);
% all_frames = zeros(256,256,num_frames);
% fileID = fopen([path1 '\' fnames{1}],'r');
% for n_fr = 1:num_frames
%     I = fread(fileID, 256*256, precis);
%     Ir = reshape(I,256, 256, [])';
%     all_frames(:,:,n_fr) = Ir;
% end
% fclose(fileID);

end