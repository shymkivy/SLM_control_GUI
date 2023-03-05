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
if strcmpi(ops.SLM_type, 'BNS1920')
    ops = f_SLM_BNS1920_initialize(ops);
elseif strcmpi(ops.SLM_type, 'BNS512OD')
    ops = f_SLM_BNS512OD_initialize(ops);
elseif strcmpi(ops.SLM_type, 'BNS512OD_sdk3')
    ops = f_SLM_BNS512OD_sdk3_initialize(ops);
elseif strcmpi(ops.SLM_type, 'BNS512')
    ops = f_SLM_BNS512_initialize(ops);
else
    error('Undefined SLM in f_SLM_initialize');
end

%% load imagegen library which is in new BNS 1920 slm sdk path

%f_SLM_BNS_load_imagegen(ops);

end