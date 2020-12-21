function AO_wf = f_SLM_AO_get_correction(app, reg_name, Z)

if ~exist('reg_name', 'var')
    reg_name = app.CurrentregionDropDown.Value;
end
[~,~,~,reg1] = f_SLM_get_reg_deets(app,reg_name);

if ~exist('Z', 'var')
    Z = app.current_SLM_coord.xyzp(:,3)*1e6;
end
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

%figure; imagesc(AO_wf)

end