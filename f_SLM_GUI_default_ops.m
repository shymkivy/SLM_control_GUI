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
idx = 1;
SLM_params(idx).SLM_name = 'BNS1920';
SLM_params(idx).height = 1152;
SLM_params(idx).width = 1920;
SLM_params(idx).lut_fname = 'linear_cut_940_1064.lut';
SLM_params(idx).SLM_SDK_dir = [];
SLM_params(idx).regions_use = {'Right half', 'Left half', 'Full SLM'};
%lut_fname =  'linear.lut'; %'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_940_1r_11_10_20_14h_37m_from_linear.lut';
%lut_fname =  'linear_cut_940_1064.lut';

idx = 2;
SLM_params(idx).SLM_name = 'BNS512OD'; % 901D with overdrive
SLM_params(idx).height = 512;
SLM_params(idx).width = 512;
SLM_params(idx).init_lut_fname = 'SLM_3329_20150303.txt'; % SLM_3329_20150303.txt; slm4317_test_regional.txt
SLM_params(idx).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
SLM_params(idx).regions_use = {'Full SLM'};

idx = 3;
SLM_params(idx).SLM_name = 'BNS512'; % prairie 1
SLM_params(idx).height = 512;
SLM_params(idx).width = 512;
SLM_params(idx).lut_fname = 'linear.lut';
SLM_params(idx).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink\SDK';
SLM_params(idx).regions_use = {'Full SLM'};
%% some default general params
% 20X olympus specific params
% ops.objective_mag = 20; %
% ops.effective_NA = 0.48; % 0.48 for 20x; 
% ops.FOV_size = 637.4; % in um

% determines the size of all radial patterns (defocus and zernike)
%ops.beam_diameter = 1152;   % in pixels, unused 
ops.objective_RI = 1.33;    % used in defocus functions
%ops.wavelength = 940;       % in nm    

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
idx = 1;
region_params(idx).obj_name = '25X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Right half';
region_params(idx).wavelength = 940;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.61; % 11/11/21 0.62  before 11/11/21 0.605;
region_params(idx).lut_correction_fname = 'photodiode_lut_940_slm5221_4_7_22_right_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_25x_maitai_11_11_21.mat';
region_params(idx).AO_correction_fname = 'AO_correction_25x_maitai_11_21_21.mat';
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 0]; % baseline beam offset
region_params(idx).xy_over_z_offset = [0.027 -0.012]; % axial beam offset by z

idx = 2;
region_params(idx).obj_name = '25X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Left half';
region_params(idx).wavelength = 1064;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.565; % 0.565 from 11/11/21% 0.51 before
region_params(idx).lut_correction_fname = 'photodiode_lut_1064_slm5221_4_7_22_left_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_25x_fianium_11_11_21.mat';
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = 'Fianium_0z_4_10_22_pw_corr.mat';
region_params(idx).xyz_offset = [0 0 -6];  % baseline beam offset
region_params(idx).xy_over_z_offset = [-0.018 0.0095]; % axial beam offset by z
region_params(idx).beam_dump_xy = [250, 0];

%% 20x with BNS1920
idx = 3;
region_params(idx).obj_name = '20X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Right half'; % imaging
region_params(idx).wavelength = 940;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.48;
region_params(idx).lut_correction_fname = 'photodiode_lut_940_slm5221_4_7_22_right_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_20x_maitai_z6_12_21_20.mat';
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 0];
region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z

idx = 4;
region_params(idx).obj_name = '20X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Left half'; % stimulation
region_params(idx).wavelength = 1064;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.415;
region_params(idx).lut_correction_fname = 'photodiode_lut_1064_slm5221_4_7_22_left_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_20x_fianium_z1_12_21_20.mat';
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 -6];
region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z

%% default directories

% where to save outputs
ops.calibration_dir = [ops.GUI_dir '\..\SLM_calibration'];
ops.save_dir = [ops.GUI_dir '\..\SLM_outputs'];

% GUI subdirectories
ops.lut_dir = [ops.calibration_dir '\lut_calibration'];
ops.xyz_calibration_dir = [ops.calibration_dir '\xyz_calibration'];
ops.AO_correction_dir = [ops.calibration_dir '\AO_correction'];
ops.point_weight_correction_dir = [ops.calibration_dir '\point_weight_correction'];

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
% xyz_pts formats: [x y z]; [x y z weight]; [pat x y z weight]
xyz_patterns(1).pat_name = 'Multiplane';
xyz_patterns(1).xyz_pts = [8 0 -50; 0 8 -25; 8 0 0; 0 8 25; 8 0 50;];
xyz_patterns(1).SLM_region = 'Right half';

xyz_patterns(2).pat_name = 'Stim';
xyz_patterns(2).xyz_pts = [0 0 0];
xyz_patterns(2).SLM_region = 'Left half';

%% 
pw_calibration.smooth_std = 1;
pw_calibration.min_thresh = 0.3;
pw_calibration.pw_sqrt = 1;

%% save stuff
ops.objectives = objectives;
ops.SLM_params = SLM_params;
ops.region_params = region_params;
ops.region_list = region_list;
ops.xyz_patterns = xyz_patterns;
ops.pw_calibration = pw_calibration;
app.SLM_ops = ops;

end