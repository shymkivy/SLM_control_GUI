function f_SLM_GUI_default_ops(app)

if isprop(app, 'SLM_ops')
    ops = app.SLM_ops;
else
    ops = struct;
end

%% Which SLM????
% 0 = BNS 1920
% 1 = BNS 512 with OverDrive (OD)
ops.SLM_type = 0; 

%% default lut
if ops.SLM_type == 0
    %ops.lut_fname =  'linear.lut'; %'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
    %ops.lut_fname =  'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';
    ops.lut_fname =  'photodiode_lut_940_1r_11_10_20_14h_37m_from_linear.lut';
else
    % Prairie 1, sdk with no overdrive. Will not accept initial regional lut
    ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink\SDK';
    
    % 901D, with overdrive, requires initial regional lut (init_lut_fname)
    %ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
    %ops.init_lut_fname =  'SLM_3329_20150303.txt'; % SLM_3329_20150303.txt; slm4317_test_regional.txt
end

%%
if ops.SLM_type == 0
    ops.height = 1152;      % automatically get from SLM, only is used if slm fails to activate
    ops.width = 1920;       % automatically get from SLM
else
    ops.height = 512;
    ops.width = 512;
end

% 20X olympus specific params
% ops.objective_mag = 20; %
% ops.effective_NA = 0.48; % 0.48 for 20x; 
% ops.FOV_size = 637.4; % in um

% % 25X olympus specific params
ops.objective_mag = 25;
ops.effective_NA = 0.605; % %1.05; 0.6050 for 25X 1152beam
ops.FOV_size = 511; % in um FOR LEFT SIDE .52NA

% determines the size of all radial patterns (defocus and zernike)
ops.beam_diameter = 1152;   % in pixels, unused 

ops.objective_RI = 1.33;    % used in defocus functions
ops.wavelength = 940;       % in nm    

ops.X_offset = 0;           % amount to offset with X offset
ops.Y_offset = 10;          % amount to offset with Y offset

ops.ref_offset = 50;    % reference image offset for checking scan sequence 


ops.NI_DAQ_dvice = 'dev2';
ops.NI_DAQ_counter_channel = 0;
ops.NI_DAQ_AI_channel = 0;
ops.NI_DAQ_AO_channel = 0;

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

%%
app.SLM_ops = ops;
%%
if ops.SLM_type == 0
    % defauld roi list
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
    roi1.effective_NA = 0.415; % .52 FOR 25X
    roi1.lateral_affine_transform = {'lateral_calib_fianium_z1_12_21_20.mat'};
    app.region_list = [app.region_list; roi1];

    roi1.name_tag = {'Right half'};
    roi1.height_range = [0, 1];
    roi1.width_range = [0.5, 1];
    roi1.wavelength = 940;
    roi1.effective_NA = 0.48;
    roi1.lateral_affine_transform = {'lateral_calib_maitai_z6_12_21_20.mat'}; % lateral_affine_transform_mat_z2_um_25x_11_25_20.mat
    app.region_list = [app.region_list; roi1];

    % default xyz pattern
    pat1.name_tag = {'Multiplane'};
    pat1.xyz_pts = [];
    pat1.SLM_region = {'Right half'};
    app.xyz_patterns = [app.xyz_patterns; pat1];

end

%% specific for BNS 512
if ops.SLM_type == 1
    %ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
    %ops.init_reg_lut_fname = 'SLM_3329_20150303.txt';    
    % dont need
    %ops.cal_image_path = '';    % default will create blank
    
    %% defauld roi list
    roi1.name_tag = {'Full SLM'};
    roi1.height_range = [0, 1];
    roi1.width_range = [0, 1];
    roi1.wavelength = 940;
    roi1.effective_NA = 0.48;
    roi1.lateral_affine_transform = {}; %'lateral_calib_maitai_z6_12_21_20.mat'
    app.region_list = [app.region_list; roi1];
    
    %% default xyz pattern
    pat1.name_tag = {'Multiplane'};
    pat1.xyz_pts = [];
    pat1.SLM_region = {'Full SLM'};
    app.xyz_patterns = [app.xyz_patterns; pat1];
    
end

end