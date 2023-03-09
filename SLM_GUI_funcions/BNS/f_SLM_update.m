function f_SLM_update(ops, image_pointer)

if ops.SDK_created
    
    if strcmpi(ops.SLM_type, 'BNS1920')
        if ~ops.sdk3_ver
            f_SLM_BNS1920_sdk4_update(ops, image_pointer);
        else
            f_SLM_BNS1920_sdk3_update(ops, image_pointer);
        end
    elseif strcmpi(ops.SLM_type, 'BNS512OD')
        if ~ops.sdk3_ver
            f_SLM_BNS512OD_sdk4_update(ops, image_pointer);
        else
            f_SLM_BNS512OD_sdk3_update(ops, image_pointer);
        end
    elseif strcmpi(ops.SLM_type, 'BNS512')
        if ~ops.sdk3_ver
            f_SLM_BNS512_sdk4_update(ops, image_pointer);
        else
            f_SLM_BNS512_sdk3_update(ops, image_pointer);
        end
    else
        error('Undefined SLM in f_SLM_update');
    end
else
    disp('SLM is not active')
end


end