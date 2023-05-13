function [wf_out, params] = f_sg_AO_compute_wf(app, reg_params)
reg1 = f_sg_get_reg_deets(app, reg_params.reg_name); 

params = struct;
params.phase_diameter = reg_params.phase_diameter;
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
            AO_corr1 = data.AO_correction;
            
            if isfield(AO_corr1, 'AO_data')
                AO_correction_all = cat(1,AO_corr1.AO_data.AO_correction);
                max_modes = max(AO_correction_all(:,1));
            end
            maxZn = ceil((-1 + sqrt(1 + 4*max_modes*2))/2)-1;
            zernike_nm_all = f_sg_get_zernike_mode_nm(0:maxZn);
            wf_out.all_modes = f_sg_gen_zernike_modes(reg1, zernike_nm_all);

            if isfield(AO_corr1, 'fit_fx')  % load
                disp('Loading AO');
                wf_out.fit_fx = AO_corr1.fit_fx;
                wf_out.fit_weights = AO_corr1.fit_weights;
                wf_out.fit_eq = AO_corr1.fit_eq;
                if isfield(AO_corr1, 'fit_defocus_comp')
                    wf_out.fit_defocus_comp = AO_corr1.fit_defocus_comp;
                end
            elseif isfield(AO_corr1, 'AO_data') % compute 
                disp('Computing AO');
                ao_data = AO_corr1.AO_data;
                wf_out.AO_data = ao_data;
                
                fit_params.ignore_sherical = app.IgnoreallsphericalCheckBox.Value;
                fit_params.fit_type = app.FitmethodDropDown.Value;
                fit_params.spline_smoothing_param = app.splinesmparam01EditField.Value;
                fit_params.constrain_z0 = app.Constrainz0CheckBox.Value;
                fit_params.ignore_zeros = app.Ignore0CheckBox.Value;
                fit_params.plot_corr = app.PlotfitCheckBox.Value;
                fit_params.plot_extra = app.PlotextraCheckBox.Value;
                AO_correction = f_sg_AO_do_zernike_fit(ao_data, 1:max_modes, fit_params);
                
                wf_out.fit_weights = AO_correction.fit_weights;
                wf_out.fit_eq = AO_correction.fit_eq;
                wf_out.fit_fx = AO_correction.fit_fx;
            end
        end
    end
else
    wf_out = [];
end
end