function f_sg_save_current_holo(app)

holo_image = app.SLM_Image;
holo_image = f_sg_AO_add_correction(app,holo_image, app.current_SLM_AO_Image);
holo_phase = angle(holo_image) + pi;
holo_phase2 = uint8((holo_phase/(2*pi))*255);

temp_time = clock;
file_time = sprintf('%d_%d_%d_%dh_%dm',temp_time(2), temp_time(3), temp_time(1)-2000, temp_time(4), temp_time(5));

[file,path] = uiputfile([app.SLM_ops.save_patterns '\holo_' file_time '.bmp']); % {'*.bmp';'*.*', 'pattern.bmp'}, 

imwrite(holo_phase2, [path file])

end