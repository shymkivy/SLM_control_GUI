function f_SLM_BNS_update_lut(ops)

lut_path = [ops.lut_dir '\' ops.lut_fname];
calllib('Blink_C_wrapper', 'Load_LUT_file',ops.board_number, lut_path);

end