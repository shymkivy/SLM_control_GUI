function f_SLM_BNS_update_lut(ops)

global_lut_path = [ops.lut_dir '\' ops.global_lut_fname];
calllib('Blink_C_wrapper', 'Load_LUT_file',ops.board_number, global_lut_path);

end