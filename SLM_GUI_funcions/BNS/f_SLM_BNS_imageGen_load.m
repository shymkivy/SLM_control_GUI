function ops = f_SLM_BNS_imageGen_load(ops)

%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% directories
% library path
if ~isfield(ops, 'imageGen_dir') % where is SDK
    ops.imageGen_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
end

%%
% This loads the image generation functions
if exist([ops.imageGen_dir '\ImageGen.dll'], 'file')
    if ~libisloaded('ImageGen')
        loadlibrary([ops.imageGen_dir '\ImageGen.dll'], [ops.imageGen_dir '\ImageGen.h']);
    end
else
    warning('image gen dll does not exist in %s', ops.imageGen_dir)
end

end