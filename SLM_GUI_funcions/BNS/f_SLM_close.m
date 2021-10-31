function ops = f_SLM_close(ops)

if strcmpi(ops.SLM_type, 'BNS1920')
    ops = f_SLM_BNS1920_close(ops);
elseif strcmpi(ops.SLM_type, 'BNS512OD') || strcmpi(ops.SLM_type, 'BNS512')
    ops = f_SLM_BNS512OD_close(ops);
else
    error('Undefined SLM in f_SLM_close');
end
    
end