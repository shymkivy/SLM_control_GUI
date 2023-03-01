function [SLM_phase, holo_phase, SLM_phase_corr, holo_phase_corr, AO_phase] = f_sg_xyz_gen_SLM_phase(app, coord, reg1, apply_AO)

% if ~exist('apply_AO', 'var')
%     apply_AO = app.ApplyAOcorrectionButton.Value;
% end

if strcmpi(app.GenXYZpatmethodDropDown.Value, 'synthesis')

    holo_phase = f_sg_PhaseHologram2(coord, reg1);

    complex_exp = sum(exp(1i*(holo_phase)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3);

    SLM_phase = angle(complex_exp);

    % add ao corrections
    if apply_AO
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
        holo_phase_corr = holo_phase+AO_phase;
    else
        AO_phase = [];
        holo_phase_corr = holo_phase;
    end

    complex_exp_corr = sum(exp(1i*(holo_phase_corr)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3);
    SLM_phase_corr = angle(complex_exp_corr);

elseif strcmpi(app.GenXYZpatmethodDropDown.Value, 'GS meadowlark')
    SLM_phase = f_sg_xyz_gen_holo_MGS(app, coord, reg1);

    holo_phase = [];
    holo_phase_corr = [];
    SLM_phase_corr = SLM_phase;
    AO_phase = [];
end

end