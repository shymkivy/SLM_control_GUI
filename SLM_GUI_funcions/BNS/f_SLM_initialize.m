function ops = f_SLM_initialize(ops)

%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% set default SLM if not specified
if ~isfield(ops, 'SLM_type')
    ops.SLM_type = 0; % BNS1920 is standard
end

%%
if ops.SLM_type == 0
    ops = f_SLM_BNS1920_initialize(ops);
elseif ops.SLM_type == 1
    ops = f_SLM_BNS512OD_initialize(ops);
end

%% load imagegen library which is in new BNS 1920 slm sdk path

f_SLM_BNS_load_imagegen();

end