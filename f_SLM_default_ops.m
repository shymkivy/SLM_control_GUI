function ops = f_SLM_default_ops(GUI_dir)

ops = struct;

%% Which SLM is default ???? 
ops.SLM_type = 'BNS1920'; % 'BNS1920', 'BNS512', 'BNS512OD', 'BNS512OD_sdk3'
% BNS1920
% BNS512OD with OverDrive (OD) in 901D
% BNS512 standard on prairie 1 or 901 not using OD

ops.sdk3_ver = 0; % using the old sdk 3 library?

%% for meadowlark ImageGen and GS algorithm

ops.imageGen_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_1920_4_857';       % newer version, different functs
%ops.imageGen_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_1920_3_528';       % older version

ops.GS_z_factor = 50/39.7;  % scaling factor for meadowlark GS defocus to match effNA
ops.GS_num_iterations = 50; % number of iterations for meadowlark GS optimization

%% SLM specific params
idx = 1;
SLM_params(idx).SLM_name = 'BNS1920';
SLM_params(idx).height = 1152;
SLM_params(idx).width = 1920;
SLM_params(idx).lut_fname = 'linear_cut_940_1064.lut';
%SLM_params(idx).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
SLM_params(idx).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_1920_4_857';
SLM_params(idx).SLM_SDK3_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_1920_3_528';
SLM_params(idx).regions_use = {'Right half', 'Left half', 'Full SLM'};
%lut_fname =  'linear.lut'; %'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_940_1r_11_10_20_14h_37m_from_linear.lut';
%lut_fname =  'linear_cut_940_1064.lut';

idx = idx + 1;
SLM_params(idx).SLM_name = 'BNS512OD'; % 901D with overdrive
SLM_params(idx).height = 512;
SLM_params(idx).width = 512;
SLM_params(idx).init_lut_fname = 'SLM_3329_20150303.txt'; % SLM_3329_20150303.txt; slm4317_test_regional.txt
SLM_params(idx).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_512_4_851';
SLM_params(idx).SLM_SDK3_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_512_3_519';
SLM_params(idx).regions_use = {'Full SLM'};

idx = idx + 1;
SLM_params(idx).SLM_name = 'BNS512'; % prairie 1
SLM_params(idx).height = 512;
SLM_params(idx).width = 512;
SLM_params(idx).lut_fname = 'slm4317_at1064_P8.lut';
SLM_params(idx).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_512_4_851';
SLM_params(idx).SLM_SDK3_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_512_3_519';
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

ops.zoom = 1.2;

ops.NI_DAQ_dvice = 'dev2';
ops.NI_DAQ_counter_channel = 0;
ops.NI_DAQ_AI_channel = 0;
ops.NI_DAQ_AO_channel = 0;

ops.orbital_mag = 1;

ops.default_AO_scan_path = '\\PRAIRIE2000\p2f\Yuriy\SLM\PSF\AO_optimization-001';

%% objective list
idx = 1;
objectives(idx).obj_name = '25X_fat';
objectives(idx).FOV_size = 497; % w orb 511; no orb 497
objectives(idx).magnification = 25;
objectives(idx).orbital = 1;

idx = idx + 1;
objectives(idx).obj_name = '20X_fat';
objectives(idx).FOV_size = 620; % w orb 637.4; no orb est 620
objectives(idx).magnification = 20;
objectives(idx).orbital = 1;

%% specific SLM-region-objective combos params

%% 25x with BNS1920
idx = 1;
region_params(idx).obj_name = '25X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Right half';
region_params(idx).wavelength = 940;
region_params(idx).phase_diameter = 1152;
region_params(idx).zero_outside_phase_diameter = true;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.632; % 0.635 on p2obj; no orb 0.632;  w orb 0.61; no orb 0.632 % 11/11/21 0.62  before 11/11/21 0.605;
region_params(idx).lut_correction_fname = 'photodiode_lut_940_slm5221_4_7_22_right_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_25x_maitai_11_11_21.mat';
region_params(idx).AO_correction_fname =  'AO_correction_25x_maitai_poly2_4_23_23.mat'; %'AO_correction_25x_maitai_4_16_23.mat'; % 'AO_correction_25x_maitai_11_21_21.mat';
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 0]; % baseline beam offset
region_params(idx).xy_over_z_offset = [-0.02 0.006]; %no orb [-0.02 0.006]; worb[0.027 -0.012]; % axial beam offset by z
region_params(idx).zero_order_supp_phase = 5.51935; % in radians % 224 from [0 - 255]
region_params(idx).zero_order_supp_w = 0.26;
region_params(idx).beam_dump_xy = [-350, 0];

idx = idx + 1;
region_params(idx).obj_name = '25X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Left half';
region_params(idx).wavelength = 1064;
region_params(idx).phase_diameter = 1152;
region_params(idx).zero_outside_phase_diameter = true;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.565; % 0.565 from 11/11/21% 0.51 before
region_params(idx).lut_correction_fname = 'photodiode_lut_1064_slm5221_4_7_22_left_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_25x_fianium_11_11_21.mat';
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = 'Fianium_0z_4_10_22_pw_corr.mat';
region_params(idx).xyz_offset = [0 0 -6];  % baseline beam offset
region_params(idx).xy_over_z_offset = [-0.018 0.0095]; % axial beam offset by z
region_params(idx).zero_order_supp_phase = 0; % in radians % 224 from [0 - 255] 
region_params(idx).zero_order_supp_w = 0;
region_params(idx).beam_dump_xy = [-350, 0];

%% 20x with BNS1920
idx = idx + 1;
region_params(idx).obj_name = '20X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Right half'; % imaging
region_params(idx).wavelength = 940;
region_params(idx).phase_diameter = 1152;
region_params(idx).zero_outside_phase_diameter = true;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.503; % 0.48 with orb; 0.503 no orb % 25x eff NA /25*20
region_params(idx).lut_correction_fname = 'photodiode_lut_940_slm5221_4_7_22_right_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_20x_maitai_z6_12_21_20.mat';
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 0];
region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z
region_params(idx).zero_order_supp_phase = 0; % in radians % 224 from [0 - 255] 
region_params(idx).zero_order_supp_w = 0;
region_params(idx).beam_dump_xy = [-350, 0];

idx = idx + 1;
region_params(idx).obj_name = '20X_fat';
region_params(idx).SLM_name = 'BNS1920';
region_params(idx).reg_name = 'Left half'; % stimulation
region_params(idx).wavelength = 1064;
region_params(idx).phase_diameter = 1152;
region_params(idx).zero_outside_phase_diameter = true;
region_params(idx).beam_diameter = 1152;
region_params(idx).effective_NA = 0.415;
region_params(idx).lut_correction_fname = 'photodiode_lut_1064_slm5221_4_7_22_left_half_corr2_sub_region_interp_corr.mat';
region_params(idx).xyz_affine_tf_fname = 'xyz_calib_20x_fianium_z1_12_21_20.mat';
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 -6];
region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z
region_params(idx).zero_order_supp_phase = 0; % in radians % 224 from [0 - 255] 
region_params(idx).zero_order_supp_w = 0;
region_params(idx).beam_dump_xy = [-350, 0];

%% 25x with BNS512
idx = idx + 1;
region_params(idx).obj_name = '25X_fat';
region_params(idx).SLM_name = 'BNS512';
region_params(idx).reg_name = 'Full SLM';
region_params(idx).wavelength = 1040;
region_params(idx).phase_diameter = 512;
region_params(idx).zero_outside_phase_diameter = true;
region_params(idx).beam_diameter = 512;
region_params(idx).effective_NA = 0.5; %
region_params(idx).lut_correction_fname = [];
region_params(idx).xyz_affine_tf_fname = [];
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 0]; % baseline beam offset
region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z
region_params(idx).zero_order_supp_phase = 0; % in radians % 224 from [0 - 255] 
region_params(idx).zero_order_supp_w = 0;
region_params(idx).beam_dump_xy = [0, 0];

%% 25x with BNS512 overdrive plus

idx = idx + 1;
region_params(idx).obj_name = '25X_fat';
region_params(idx).SLM_name = 'BNS512OD';
region_params(idx).reg_name = 'Full SLM';
region_params(idx).wavelength = 1040;
region_params(idx).phase_diameter = 512;
region_params(idx).zero_outside_phase_diameter = true;
region_params(idx).beam_diameter = 512;
region_params(idx).effective_NA = 0.5; 
region_params(idx).lut_correction_fname = [];
region_params(idx).xyz_affine_tf_fname = [];
region_params(idx).AO_correction_fname = [];
region_params(idx).point_weight_correction_fname = [];
region_params(idx).xyz_offset = [0 0 0]; % baseline beam offset
region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z
region_params(idx).zero_order_supp_phase = 0; % in radians % 224 from [0 - 255] 
region_params(idx).zero_order_supp_w = 0;
region_params(idx).beam_dump_xy = [0, 0];

%% default directories

if ~exist('GUI_dir', 'var')
     GUI_dir = fileparts(mfilename('fullpath'));
end
ops.GUI_dir = GUI_dir;
 
% where to save outputs
ops.calibration_dir = [ops.GUI_dir '\..\SLM_calibration'];
ops.save_dir = [ops.GUI_dir '\..\SLM_outputs'];

% GUI subdirectories
ops.lut_dir = [ops.calibration_dir '\lut_calibration'];
ops.xyz_calibration_dir = [ops.calibration_dir '\xyz_calibration'];
ops.AO_correction_dir = [ops.calibration_dir '\AO_correction'];
ops.point_weight_correction_dir = [ops.calibration_dir '\point_weight_correction'];

ops.custom_phase_dir = [ops.calibration_dir '\custom_phase'];
ops.pattern_editor_dir = [ops.calibration_dir '\pattern_editor'];

ops.save_AO_dir = [ops.save_dir '\AO_outputs'];
ops.save_patterns_dir = [ops.save_dir '\saved_patterns'];
ops.save_lut_dir = [ops.save_dir '\lut_calibration'];

% directory from microscope computer where frames are saved during AO optimization
ops.AO_recording_dir = ''; % E:\data\SLM\AO\12_4_20\zernike_100um_1modes-001

%% defauld regions list
idx = 1;
region_list(idx).reg_name = 'Right half';
region_list(idx).height_range = [0, 1];
region_list(idx).width_range = [0.5, 1];

idx = idx + 1;
region_list(idx).reg_name = 'Left half';
region_list(idx).height_range = [0, 1];
region_list(idx).width_range = [0, 0.5];

idx = idx + 1;
region_list(idx).reg_name = 'Full SLM';
region_list(idx).height_range = [0, 1];
region_list(idx).width_range = [0, 1];


%% default xyz pattern - regions
% xyz_pts formats: [x y z]; [x y z weight]; [pat x y z weight]
idx = 1;
xyz_patterns(idx).pat_name = 'Multiplane';
xyz_patterns(idx).xyz_pts = [8 0 -50; 0 8 -25; 8 0 0; 0 8 25; 8 0 50;];
xyz_patterns(idx).SLM_region = 'Right half';

idx = idx + 1;
xyz_patterns(idx).pat_name = 'Stim';
xyz_patterns(idx).xyz_pts = [8 0 0];
xyz_patterns(idx).SLM_region = 'Left half';

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

end