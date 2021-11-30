function f_sg_save_current_holo(app)

SLM_phase_corr_lut = app.SLM_phase_corr_lut;

temp_time = clock;
file_time = sprintf('%d_%d_%d_%dh_%dm',temp_time(2), temp_time(3), temp_time(1)-2000, temp_time(4), temp_time(5));

[file,path] = uiputfile([app.SLM_ops.save_patterns_dir '\holo_' file_time '.bmp']); % {'*.bmp';'*.*', 'pattern.bmp'}, 

if file
    imwrite(SLM_phase_corr_lut, [path file]);
    disp('Saved');
end

end