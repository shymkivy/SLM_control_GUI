classdef UtilObj < handle
    properties
        gui_dir = '';
        gui_ops;
    end
    methods
        function ops = UtilObj(gui_ops)
            ops.gui_ops = gui_ops;
            ops.gui_dir = gui_ops.GUI_dir;
        end
        function init_dir(ops2)
            
            ops = ops2.gui_ops;
            for dir1 = {ops.lut_dir, ops.xyz_calibration_dir, ops.AO_correction_dir, ops.point_weight_correction_dir}
                if ~exist(dir1{1}, 'dir')
                    fprintf('Creating dir: %s\n', dir1{1});
                    mkdir(dir1{1});
                end
            end
        end
    end
end