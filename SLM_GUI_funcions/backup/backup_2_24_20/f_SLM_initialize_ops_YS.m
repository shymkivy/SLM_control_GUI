function ops = f_SLM_initialize_ops_YS(ops)

if ~exist('ops', 'var')
    ops = struct;
end

% library path
ops.path_library = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';

% - In your program you should use the path to your custom LUT as opposed to linear LUT
ops.path_lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\linear.LUT';

end