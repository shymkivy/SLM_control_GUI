function Y = f_collect_prairie_tiffs3(load_stack)
% load the PrairieView output tif images and combine them into single
% movie stack h5 or tif. h5 is much faster

if ~exist(load_stack, 'dir'); Error(['Pipeline Error: Directory ' load_stack ' does not exist']); end

dir_names = dir([load_stack, '\*.tif']);
tremp_frame = imread([load_stack, '\',  dir_names(1).name], 'tif');
dim = size(tremp_frame);
T = numel(dir_names);

if ~T; Error('Pipeline Error: No tiff files in specified folters'); end

Y = zeros([dim, T], 'uint16');

% load
hh = waitbar(0, 'Loading Prairie tiffs');
for n_frame = 1:T
    Y(:,:,n_frame) = imread([load_stack, '\', dir_names(n_frame).name], 'tif');
    waitbar((n_frame)/T, hh);
end
close(hh)


end