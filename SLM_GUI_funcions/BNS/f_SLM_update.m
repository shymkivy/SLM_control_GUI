function f_SLM_update(ops, image_pointer)

if strcmpi(ops.SLM_type, 'BNS1920')
    f_SLM_BNS1920_update(ops, image_pointer);
elseif strcmpi(ops.SLM_type, 'BNS512OD')
    f_SLM_BNS512OD_update(ops, image_pointer);
elseif strcmpi(ops.SLM_type, 'BNS512')
    f_SLM_BNS512_update(ops, image_pointer);
else
    error('Undefined SLM in f_SLM_update');
end

end