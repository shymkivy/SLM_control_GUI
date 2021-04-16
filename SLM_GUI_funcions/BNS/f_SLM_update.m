function f_SLM_update(ops, image)

if ops.SLM_type == 0
    f_SLM_BNS1920_update(ops, image);
elseif ops.SLM_type == 1
    f_SLM_BNS512OD_update(ops, image);
end

end