function f_SLM_GUI_default_ops(app)

if isprop(app, 'SLM_ops')
    ops = app.SLM_ops;
else
    ops = struct;
end

%% Which SLM is default ???? 
ops.SLM_type = 'BNS1920'; % 'BNS1920', 'BNS512', 'BNS512OD'
% BNS1920
% BNS512OD with OverDrive (OD) in 901D
% BNS512 standard on prairie 1 or 901 not using OD

%% SLM specific params
SLM_params(1).SLM_name = 'BNS1920';
SLM_params(1).height = 1152;
SLM_params(1).width = 1920;
SLM_params(1).lut_fname = 'linear_cut_940_1064.lut';
SLM_params(1).SLM_SDK_dir = [];
SLM_params(1).regions_use = {'Right half', 'Left half', 'Full SLM'};
%lut_fname =  'linear.lut'; %'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_940_1r_11_10_20_14h_37m_from_linear.lut';
%lut_fname =  'linear_cut_940_1064.lut';

SLM_params(2).SLM_name = 'BNS512OD'; % 901D with overdrive
SLM_params(2).height = 512;
SLM_params(2).width = 512;
SLM_params(2).init_lut_fname = 'SLM_3329_20150303.txt'; % SLM_3329_20150303.txt; slm4317_test_regional.txt
SLM_params(2).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
SLM_params(2).regions_use = {'Full SLM'};

SLM_params(3).SLM_name = 'BNS512'; % prairie 1
SLM_params(3).height = 512;
SLM_params(3).width = 512;
SLM_params(3).lut_fname = 'linear.lut';
SLM_params(3).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink\SDK';
SLM_params(3).regions_use = {'Full SLM'};
%% some default general params
% 20X olympus specific params
% ops.objective_mag = 20; %
% ops.effective_NA = 0.48; % 0.48 for 20x; 
% ops.FOV_size = 637.4; % in um

% determines the size of all radial patterns (defocus and zernike)
%ops.beam_diameter = 1152;   % in pixels, unused 
ops.objective_RI = 1.33;    % used in defocus functions
%ops.wavelength = 940;       % in nm    

ops.X_offset = 0;           % amount to offset with X offset
ops.Y_offset = 10;          % amount to offset with Y offset
ops.ref_offset = 50;    % reference image offset for checking scan sequence 

ops.NI_DAQ_dvice = 'dev2';
ops.NI_DAQ_counter_channel = 0;
ops.NI_DAQ_AI_channel = 0;
ops.NI_DAQ_AO_channel = 0;

%% objective list

objectives(1).obj_name = '25X_fat';
objectives(1).FOV_size = 511;

objectives(2).obj_name = '20X_fat';
objectives(2).FOV_size = 637.4;

%% specific SLM-region-objective combos params

%% 25x with BNS1920
region_params(1).obj_name = '25X_fat';
region_params(1).SLM_name = 'BNS1920';
region_params(1).reg_name = 'Right half';
region_params(1).wavelength = 940;
region_params(1).beam_diameter = 1152;
region_params(1).effective_NA = 0.605;
region_params(1).lut_correction_fname = [];
region_params(1).xyz_affine_tf_fname = 'lateral_calib_maitai_z6_12_21_20.mat';
region_params(1).AO_correction_fname = 'all_zernike_data_12_12_20.mat';


region_params(2).obj_name = '25X_fat';
region_params(2).SLM_name = 'BNS1920';
region_params(2).reg_name = 'Left half';
region_params(2).wavelength = 1064;
region_params(2).beam_diameter = 1152;
region_params(2).effective_NA = 0.51; % still to calibrate
region_params(2).lut_correction_fname = [];
region_params(2).xyz_affine_tf_fname = 'lateral_calib_fianium_z1_12_21_20.mat';
region_params(2).AO_correction_fname = [];

%% 20x with BNS1920
region_params(3).obj_name = '20X_fat';
region_params(3).SLM_name = 'BNS1920';
region_params(3).reg_name = 'Right half'; % imaging
region_params(3).wavelength = 940;
region_params(3).beam_diameter = 1152;
region_params(3).effective_NA = 0.48;
region_params(3).lut_correction_fname = [];
region_params(3).xyz_affine_tf_fname = 'lateral_calib_maitai_z6_12_21_20.mat';
region_params(3).AO_correction_fname = [];


region_params(4).obj_name = '20X_fat';
region_params(4).SLM_name = 'BNS1920';
region_params(4).reg_name = 'Left half'; % stimulation
region_params(4).wavelength = 1064;
region_params(4).beam_diameter = 1152;
region_params(4).effective_NA = 0.415;
region_params(4).lut_correction_fname = [];
region_params(4).xyz_affine_tf_fname = 'lateral_calib_fianium_z1_12_21_20.mat';
region_params(4).AO_correction_fname = [];

%% default directories

% where to save outputs
ops.calibration_dir = [ops.GUI_dir '\..\SLM_calibration'];
ops.save_dir = [ops.GUI_dir '\..\SLM_outputs'];

% GUI subdirectories
ops.lut_dir = [ops.calibration_dir '\lut_calibration'];
ops.xyz_calibration_dir = [ops.calibration_dir '\xyz_calibration'];
ops.AO_correction_dir = [ops.calibration_dir '\AO_correction'];
ops.custom_phase_dir = [ops.calibration_dir '\custom_phase'];
ops.patter_editor_dir = [ops.calibration_dir '\pattern_editor'];

ops.save_AO_dir = [ops.save_dir '\AO_outputs'];
ops.save_patterns_dir = [ops.save_dir '\saved_patterns'];

% directory from microscope computer where frames are saved during AO optimization
ops.AO_recording_dir = ''; % E:\data\SLM\AO\12_4_20\zernike_100um_1modes-001

%% defauld regions list

region_list(1).reg_name = 'Right half';
region_list(1).height_range = [0, 1];
region_list(1).width_range = [0.5, 1];

region_list(2).reg_name = 'Left half';
region_list(2).height_range = [0, 1];
region_list(2).width_range = [0, 0.5];

region_list(3).reg_name = 'Full SLM';
region_list(3).height_range = [0, 1];
region_list(3).width_range = [0, 1];


%% default xyz pattern - regions
xyz_patterns(1).pat_name = 'Multiplane';
xyz_patterns(1).xyz_pts = [];
xyz_patterns(1).SLM_region = 'Right half';

xyz_patterns(2).pat_name = 'Stim';
xyz_patterns(2).xyz_pts = [];
xyz_patterns(2).SLM_region = 'Left half';

%% save stuff
ops.objectives = objectives;
ops.SLM_params = SLM_params;
ops.region_params = region_params;
ops.region_list = region_list;
ops.xyz_patterns = xyz_patterns;
app.SLM_ops = ops;

end