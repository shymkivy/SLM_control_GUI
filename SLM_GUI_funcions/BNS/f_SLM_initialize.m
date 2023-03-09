function ops = f_SLM_initialize(ops)

%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% set default SLM if not specified
if ~isfield(ops, 'SLM_type')
    warning('Undefined SLM, using BNS1920 as default')
    ops.SLM_type = 'BNS1920'; % BNS1920 is standard
end

%%
ops.SDK_created = 0;

if ~ops.sdk3_ver
    if strcmpi(ops.SLM_type, 'BNS1920')
        ops = f_SLM_BNS1920_sdk4_initialize(ops);
    elseif strcmpi(ops.SLM_type, 'BNS512OD')
        ops = f_SLM_BNS512OD_sdk4_initialize(ops);
    elseif strcmpi(ops.SLM_type, 'BNS512')
        ops = f_SLM_BNS512_sdk4_initialize(ops);
    else
        error('Undefined SLM in f_SLM_initialize');
    end
else
    ops.SLM_SDK_dir = ops.SLM_SDK3_dir;
    if strcmpi(ops.SLM_type, 'BNS1920')
        ops = f_SLM_BNS1920_sdk3_initialize(ops);
    elseif strcmpi(ops.SLM_type, 'BNS512OD')
        ops = f_SLM_BNS512OD_sdk3_initialize(ops);
    elseif strcmpi(ops.SLM_type, 'BNS512')
        ops = f_SLM_BNS512_sdk3_initialize(ops);
    else
        error('Undefined SLM in f_SLM_initialize');
    end
end

% needed for ver 4, because needs to unload library for some reason
if ~ops.SDK_created
    ops = f_SLM_close(ops);
end

%% load imagegen library which is in new BNS 1920 slm sdk path

%f_SLM_BNS_load_imagegen(ops);

end