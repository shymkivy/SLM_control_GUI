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
SLM_params(1).name = 'BNS1920';
SLM_params(1).height = 1152;
SLM_params(1).width = 1920;
SLM_params(1).lut_fname = 'linear_cut_940_1064.lut';
SLM_params(1).regions_use = {'Right half', 'Left half', 'Full SLM'};
%lut_fname =  'linear.lut'; %'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
%lut_fname =  'photodiode_lut_940_1r_11_10_20_14h_37m_from_linear.lut';
%lut_fname =  'linear_cut_940_1064.lut';

SLM_params(2).name = 'BNS512OD'; % 901D with overdrive
SLM_params(2).height = 512;
SLM_params(2).width = 512;
SLM_params(2).init_lut_fname = 'SLM_3329_20150303.txt'; % SLM_3329_20150303.txt; slm4317_test_regional.txt
SLM_params(2).SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
SLM_params(2).regions_use = {'Full SLM'};

SLM_params(3).name = 'BNS512'; % prairie 1
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

% % % 25X olympus specific params
% ops.objective_mag = 25;
% ops.effective_NA = 0.605; % %1.05; 0.6050 for 25X 1152beam
% ops.FOV_size = 511; % in um

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

%% specific objective region params

%% 25x with BNS1920
obj_params(1).name = '25X_fat';
obj_params(1).SLM = 'BNS1920';
obj_params(1).region = 'Right half';
obj_params(1).wavelength = 940;
obj_params(1).effective_NA = 0.605;
obj_params(1).beam_diameter = 1152;
obj_params(1).FOV_size = 511;
obj_params(1).xyz_affine_tf_fname = {'lateral_calib_maitai_z6_12_21_20.mat'};

obj_params(2).name = '25X_fat';
obj_params(2).SLM = 'BNS1920';
obj_params(2).region = 'Left half';
obj_params(2).wavelength = 1064;
obj_params(2).effective_NA = 0.51; % still to calibrate
obj_params(2).beam_diameter = 1152;
obj_params(2).FOV_size = 511;
obj_params(2).xyz_affine_tf_fname = {'lateral_calib_fianium_z1_12_21_20.mat'};

%% 20x with BNS1920
obj_params(3).name = '20X_fat';
obj_params(3).SLM = 'BNS1920';
obj_params(3).region = 'Right half'; % imaging
obj_params(3).wavelength = 940;
obj_params(3).effective_NA = 0.48;
obj_params(3).beam_diameter = 1152;
obj_params(3).FOV_size = 637.4;
obj_params(3).xyz_affine_tf_fname = {'lateral_calib_maitai_z6_12_21_20.mat'};

obj_params(4).name = '20X_fat';
obj_params(4).SLM = 'BNS1920';
obj_params(4).region = 'Left half'; % stimulation
obj_params(4).wavelength = 1064;
obj_params(4).effective_NA = 0.415;
obj_params(4).beam_diameter = 1152;
obj_params(4).FOV_size = 637.4;
obj_params(4).xyz_affine_tf_fname = {'lateral_calib_fianium_z1_12_21_20.mat'};

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

%% defauld roi list
region_list(1).name_tag = {'Full SLM'};
region_list(1).height_range = [0, 1];
region_list(1).width_range = [0, 1];

region_list(2).name_tag = {'Left half'};
region_list(2).height_range = [0, 1];
region_list(2).width_range = [0, 0.5];

region_list(3).name_tag = {'Right half'};
region_list(3).height_range = [0, 1];
region_list(3).width_range = [0.5, 1];

%% default xyz pattern
xyz_patterns(1).name_tag = {'Multiplane'};
xyz_patterns(1).xyz_pts = [];
xyz_patterns(1).SLM_region = {'Right half'};

xyz_patterns(2).name_tag = {'Stim'};
xyz_patterns(2).xyz_pts = [];
xyz_patterns(2).SLM_region = {'Left half'};

%% save stuff
ops.SLM_params = SLM_params;
ops.obj_params = obj_params;
ops.region_list = region_list;
ops.xyz_patterns = xyz_patterns;
app.SLM_ops = ops;

end