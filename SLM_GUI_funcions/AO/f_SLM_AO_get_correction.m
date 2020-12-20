function AO_wf = f_SLM_AO_get_correction(app, reg1, Z)
z_tol = app.AOcorrZtoleranceEditField.Value; 
Z2 = mean(Z);

if isstruct(reg1.AO_wf)
    [dist1, idx] = min(abs(Z2 - [reg1.AO_wf.Z]));
    if dist1 <= z_tol
        AO_wf = reg1.AO_wf(idx).wf_out;
    else
        AO_wf = zeros(size(reg1.AO_wf(idx).wf_out));
    end
else
    AO_wf = reg1.AO_wf;
end     

end