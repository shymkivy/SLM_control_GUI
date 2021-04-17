function f_SLM_GUI_default_ops(app)

if isprop(app, 'SLM_ops')
    ops = app.SLM_ops;
else
    ops = struct;
end

%% Which SLM????
%ops.SLM_type = 0; % this is BNS 1920
ops.SLM_type = 1; % BNS 512 with OverDrive (OD)

%% directories
% where to save outputs
ops.save_dir = [ops.GUI_dir '\..\SLM_outputs'];

% GUI subdirectories
ops.lut_dir = [ops.GUI_dir '\SLM_calibration\lut_calibration'];
ops.xyz_calibration_dir = [ops.GUI_dir '\SLM_calibration\xyz_calibration'];
ops.AO_correction_dir = [ops.GUI_dir '\SLM_calibration\AO_correction'];
ops.save_AO_dir = [ops.save_dir '\SLM_AO_outputs'];

ops.AO_recording_dir = 'E:\data\SLM\AO\12_4_20\zernike_100um_1modes-001';

%% default lut

%ops.lut_fname =  'linear.lut'; %'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%ops.lut_fname =  'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
ops.lut_fname =  'photodiode_lut_940_1r_11_10_20_14h_37m_from_linear.lut';

%% specific for BNS 512
if ops.SLM_type == 1
    ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
    %ops.cal_image_path = '';    % default will create blank
    ops.init_reg_lut_fname = 'SLM_3329_20150303.txt';
end

%% default xyz


%%
ops.height = 1152;      % automatically get from SLM
ops.width = 1920;       % automatically get from SLM

% 20X olympus specific params
% ops.objective_mag = 20; %
% ops.effective_NA = 0.48; % 0.48 for 20x; 

% % 25X olympus specific params
ops.objective_mag = 25;
ops.effective_NA = 0.605; % %1.05; 0.6050 for 25X 1152beam

% determines the size of all radial patterns (defocus and zernike)
ops.beam_diameter = 1152;       % in pixels

ops.objective_RI = 1.33;
ops.wavelength = 940;           % in nm

ops.X_offset = 0;      % amount to offset with X offset
ops.Y_offset = 10;      % amount to offset with Y offset

ops.ref_offset = 50;    % reference image offset for checking scan sequence 

ops.NI_DAQ_dvice = 'dev2';
ops.NI_DAQ_counter_channel = 0;
ops.NI_DAQ_AI_channel = 0;
ops.NI_DAQ_AO_channel = 0;

app.SLM_ops = ops;

%% defauld roi list
roi1.name_tag = {'Full SLM'};
roi1.height_range = [0, 1];
roi1.width_range = [0, 1];
roi1.wavelength = 940;
roi1.effective_NA = 0.48;
roi1.lateral_affine_transform = {'lateral_calib_maitai_z6_12_21_20.mat'};
app.region_list = [app.region_list; roi1];

roi1.name_tag = {'Left half'};
roi1.height_range = [0, 1];
roi1.width_range = [0, 0.5];
roi1.wavelength = 1064;
roi1.effective_NA = 0.415;
roi1.lateral_affine_transform = {'lateral_calib_fianium_z1_12_21_20.mat'};
app.region_list = [app.region_list; roi1];

roi1.name_tag = {'Right half'};
roi1.height_range = [0, 1];
roi1.width_range = [0.5, 1];
roi1.wavelength = 940;
roi1.effective_NA = 0.48;
roi1.lateral_affine_transform = {'lateral_calib_maitai_z6_12_21_20.mat'}; % lateral_affine_transform_mat_z2_um_25x_11_25_20.mat
app.region_list = [app.region_list; roi1];

%% default xyz pattern
pat1.name_tag = {'Multiplane'};
pat1.xyz_pts = [];
pat1.SLM_region = {'Right half'};
app.xyz_patterns = [app.xyz_patterns; pat1];

end