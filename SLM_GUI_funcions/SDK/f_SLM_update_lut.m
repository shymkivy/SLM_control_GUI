function f_SLM_update_lut(ops)

%%
ops.sdkObj.lut_path = [ops.lut_dir '\' ops.lut_fname];
ops.sdkObj.load_lut()

end