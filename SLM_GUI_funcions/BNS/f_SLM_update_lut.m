function f_SLM_update_lut(ops)

%% set default SLM if not specified
if ~isfield(ops, 'SLM_type')
    ops.SLM_type = 0; % BNS1920 is standard
end

%%
if ops.SLM_type == 0
    f_SLM_BNS1920_update_lut(ops);
elseif ops.SLM_type == 1
    disp('not update lut function available for 512 yet')
end

end