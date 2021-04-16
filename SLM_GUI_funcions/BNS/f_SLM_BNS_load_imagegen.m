function f_SLM_BNS_load_imagegen(ops)

%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% directories
% library path
if ~isfield(ops, 'imagegen_SDK_dir') % where is SDK
    ops.imagegen_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
end

addpath(ops.imagegen_SDK_dir);

%%
% This loads the image generation functions
if ~libisloaded('ImageGen')
    loadlibrary('ImageGen.dll', 'ImageGen.h');
end

end