function ops = f_SLM_close(ops)

if ops.SLM_type == 0
    f_SLM_BNS1920_close(ops);
elseif ops.SLM_type == 1
    f_SLM_BNS512OD_close(ops);
end
    
end