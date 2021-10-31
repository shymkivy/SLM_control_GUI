function f_SLM_update_lut(ops)

%%
if strcmpi(ops.SLM_type, 'BNS1920')
    f_SLM_BNS1920_update_lut(ops);
else 
    disp('Lut update onlt available for BNS1920')
end

end