function f_SLM_update(ops, image)

if strcmpi(ops.SLM_type, 'BNS1920')
    f_SLM_BNS1920_update(ops, image);
elseif strcmpi(ops.SLM_type, 'BNS512OD')
    f_SLM_BNS512OD_update(ops, image);
else
    error('Undefined SLM in f_SLM_update');
end

end