function f_SLM_BNS512_update_lut(ops)

lut_path = [ops.lut_dir '\' ops.lut_fname];
calllib('Blink_SDK_C', 'Load_LUT_file', ops.sdk, ops.board_number, lut_path);

end