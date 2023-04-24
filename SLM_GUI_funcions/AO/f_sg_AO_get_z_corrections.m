function [AO_phase, AO_corr] = f_sg_AO_get_z_corrections(app, reg1, Z)
% upload new ao to slm_ao_phase if exists

if ~exist('Z', 'var')
    Z = 0;
end
num_points = numel(Z);
z_tol = app.AOcorrZtoleranceEditField.Value;

AO_corr = [1 0];
AO_phase = zeros(sum(reg1.m_idx), sum(reg1.n_idx), num_points);
for n_point = 1:num_points
    temp_phase = AO_phase(:,:,n_point);
    if isfield(reg1, 'AO_wf')
        if ~isempty(reg1.AO_wf)
            if isstruct(reg1.AO_wf)
                if isfield(reg1.AO_wf, 'fit_weights')
                    all_modes = reg1.AO_wf.all_modes;
                    fit_weights = reg1.AO_wf.fit_weights;
                    num_fit = size(fit_weights,2)-1;
                    if num_fit == 1
                        weights = fit_weights(:,2)*Z(n_point);
                    elseif num_fit == 2
                        weights = fit_weights(:,2)*Z(n_point) + fit_weights(:,3);
                    elseif num_fit == 3
                        weights = fit_weights(:,2)*Z(n_point)^2 + fit_weights(:,3)*Z(n_point) + fit_weights(:,4);
                    end
                    AO_wf1 = sum(all_modes .* reshape(weights, 1, 1, []),3);
                    AO_corr = [fit_weights(:,1), weights];
                    AO_corr(AO_corr(:,2) == 0,:) = [];
                    temp_phase = temp_phase + AO_wf1;
                end
                if isfield(reg1.AO_wf, 'Z_corr')
                    [dist1, idx] = min(abs(Z(n_point) - [reg1.AO_wf.Z_corr.Z]));
                    if dist1 <= z_tol
                        AO_wf2 = reg1.AO_wf.Z_corr(idx).wf_out;
                    end
                    temp_phase = temp_phase + AO_wf2;
                end
            else
                temp_phase = temp_phase + reg1.AO_wf;
            end
        end
    end
    if reg1.zero_outside_phase_diameter
        temp_phase(~reg1.holo_mask) = 0;
    end
    AO_phase(:,:,n_point) = temp_phase;
end

end