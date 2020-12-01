function f_SLM_GUI_default_ops(app)

if isprop(app, 'SLM_ops')
    ops = app.SLM_ops;
else
    ops = struct;
end

%% directories
% where to save outputs
ops.save_dir = [ops.GUI_dir '\..\SLM_outputs'];

% GUI subdirectories
ops.lut_dir = [ops.GUI_dir '\SLM_calibration\lut_calibration'];
ops.xyz_calibration_dir = [ops.GUI_dir '\SLM_calibration\xyz_calibration'];
ops.AO_correction_dir = [ops.GUI_dir '\SLM_calibration\AO_correction'];
ops.save_AO_dir = [ops.save_dir '\SLM_AO_outputs'];

%% default lut

%ops.lut_fname =  'linear.lut'; %'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
ops.lut_fname =  'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';

%%
ops.height = 1152;      % automatically get from SLM
ops.width = 1920;

ops.objective_mag = 25;
ops.objective_NA = 0.95;
ops.objective_RI = 1.33;

ops.wavelength = 940;           % in nm

ops.beam_diameter = 1152;       % in pixels

ops.X_offset = 30;      % amount to offset with X offset
ops.Y_offset = 0;      % amount to offset with Y offset

ops.ref_offset = 50;    % reference image offset (makes + pattern)

ops.NI_DAQ_dvice = 'dev2';
ops.NI_DAQ_counter_channel = 0;
ops.NI_DAQ_AI_channel = 0;

app.SLM_ops = ops;

%% defauld roi list
roi1.name_tag = {'Full SLM'};
roi1.height_range = [0, 1];
roi1.width_range = [0, 1];
roi1.wavelength = 940;
app.region_list = [app.region_list; roi1];

roi1.name_tag = {'Left half'};
roi1.height_range = [0, 1];
roi1.width_range = [0, 0.5];
roi1.wavelength = 1064;
app.region_list = [app.region_list; roi1];

roi1.name_tag = {'Right half'};
roi1.height_range = [0, 1];
roi1.width_range = [0.5, 1];
roi1.wavelength = 940;
app.region_list = [app.region_list; roi1];

%% default xyz pattern
pat1.name_tag = {'Multiplane'};
pat1.xyz_pts = [];
pat1.SLM_region = {'Full SLM'};
app.xyz_patterns = [app.xyz_patterns; pat1];

end