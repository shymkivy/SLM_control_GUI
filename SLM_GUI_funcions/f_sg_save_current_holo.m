function f_sg_save_current_holo(app)

SLM_phase_corr_lut = app.SLM_phase_corr_lut;

timestamp = f_sg_get_timestamp();

[file,path] = uiputfile([app.SLM_ops.save_patterns_dir '\holo_' timestamp '.bmp']); % {'*.bmp';'*.*', 'pattern.bmp'}, 

if file
    imwrite(SLM_phase_corr_lut, [path file]);
    disp('Saved');
end

end