function [wf_out, params] = f_sg_AO_compute_wf(app, reg_params)
reg1 = f_sg_get_reg_deets(app, reg_params.reg_name); 

params = struct;
params.beam_diameter = reg_params.beam_diameter;
params.AO_iteration = 1;
params.AO_correction = [];
params.SLMm = reg1.SLMm;
params.SLMn = reg1.SLMn;

if app.ApplyAOcorrectionButton.Value
    if isempty(reg_params.AO_correction_fname)
        wf_out = [];
    elseif strcmpi(reg_params.AO_correction_fname, 'none')
        wf_out = [];
    else
        data = load([app.SLM_ops.AO_correction_dir '\' reg_params.AO_correction_fname]);
        if isstruct(data.AO_correction)
            wf_out = struct;
            if isfield(data.AO_correction, 'fit_weights')
                wf_out.fit_weights = data.AO_correction.fit_weights;
                params.beam_diameter = data.AO_correction.fit_params(1).beam_diameter;
                wf_out.wf_out_fit = f_sg_AO_compute_wf_core(wf_out.fit_weights, params);
            end
            if isfield(data.AO_correction, 'z_weights')
                wf_out.Z_corr = struct();
                for n_corr = 1:numel([data.AO_correction.z_weights])
                    wf_out.Z_corr(n_corr).Z = data.AO_correction.z_weights(n_corr).Z;
                    params.beam_diameter = data.AO_correction.z_weights(n_corr).ao_params.beam_width;

                    full_correction = cat(1,data.AO_correction.z_weights(n_corr).AO_correction{:,1});

                    wf_out.Z_corr(n_corr).wf_out = f_sg_AO_compute_wf_core(full_correction, params);
                end
            end
            
            
        else
            params.beam_diameter = data.ao_params.beam_width;

            full_correction = cat(1,data.AO_correction{:,1});

            wf_out = f_sg_AO_compute_wf_core(full_correction, params);

            params.AO_correction = full_correction;
            params.AO_iteration = size(full_correction,1)+1;
        end
    end
else
    wf_out = [];
end
end