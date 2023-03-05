function [region1, reg_params] = f_sg_reg_read(app)
%% 
region1(1).reg_name = app.RegionnameEditField.Value;
region1(1).height_range = [app.regionheightminEditField.Value, app.regionheightmaxEditField.Value];
region1(1).width_range = [app.regionwidthminEditField.Value, app.regionwidthmaxEditField.Value];

reg_params(1).obj_name = app.ObjectiveDropDown.Value;
reg_params(1).SLM_name = app.SLMtypeDropDown.Value;
reg_params(1).reg_name = app.RegionnameEditField.Value;
reg_params(1).wavelength = app.regionWavelengthnmEditField.Value;
reg_params(1).phase_diameter = app.regionPhasePatDiameterEditField.Value;
reg_params(1).effective_NA = app.regionEffectiveNAEditField.Value;

if strcmpi(app.LUTcorrectionDropDown.Value, 'none')
    reg_params(1).lut_correction_fname = [];
else
    reg_params(1).lut_correction_fname = app.LUTcorrectionDropDown.Value;
end

if strcmpi(app.XYZaffinetransformDropDown.Value, 'none')
    reg_params(1).xyz_affine_tf_fname = [];
else
    reg_params(1).xyz_affine_tf_fname = app.XYZaffinetransformDropDown.Value;
end

if strcmpi(app.AOcorrectionDropDown.Value, 'none')
    reg_params(1).AO_correction_fname = [];
else
    reg_params(1).AO_correction_fname = app.AOcorrectionDropDown.Value;
end

if strcmpi(app.PointweightcorrectionDropDown.Value, 'none')
    reg_params(1).point_weight_correction_fname = [];
else
    reg_params(1).point_weight_correction_fname = app.PointweightcorrectionDropDown.Value;
end

reg_params(1).lut_correction_data = [];
reg_params(1).xyz_affine_tf_mat = [];
reg_params(1).AO_wf = [];
reg_params(1).pw_corr_data = [];

reg_params(1).xyz_offset = [app.XoffsetEditField.Value,...
                            app.YoffsetEditField.Value,...
                            app.ZoffsetEditField.Value];
                        
reg_params(1).xy_over_z_offset = [app.XZcorrEditField.Value,...
                                  app.YZcorrEditField.Value];
                              
reg_params(1).beam_dump_xy = [app.BeamdumpXEditField.Value,...
                              app.BeamdumpYEditField.Value];

end