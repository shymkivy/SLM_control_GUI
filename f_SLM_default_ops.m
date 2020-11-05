function ops = f_SLM_default_ops(ops)
%%
if ~exist('ops', 'var')
    ops = struct;
end

%% directories
% library path
ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';

% where to save outputs
ops.save_dir = '..\SLM_outputs';

% GUI subdirectories
ops.xyz_calibration_dir = 'SLM_calibration\xyz_calibration';
ops.lut_dir = 'SLM_calibration\lut_calibration';
ops.AO_correction_dir = 'SLM_calibration\AO_correction';

ops.save_AO_dir = [ops.save_dir '\SLM_AO_outputs'];

ops.lut_dir = 'SLM_calibration\lut_calibration\';
ops.lut_init = 'linear.lut';

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

end