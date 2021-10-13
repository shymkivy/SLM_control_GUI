function f_sg_xyz_button_save_pattern(app)

coord = f_sg_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

holo_image = f_sg_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value);
app.SLM_Image = holo_image;    
app.current_SLM_coord = coord;

f_sg_upload_image_to_SLM(app);

if ~exist('add_ao', 'var')
    add_ao = 1;
end

if add_ao
    AO_wf = f_sg_AO_get_correction(app);
    SLM_image = f_sg_AO_add_correction(app, app.SLM_Image, AO_wf);
    app.current_SLM_AO_Image = AO_wf;
else
    SLM_image = app.SLM_Image;
end

holo_phase = angle(SLM_image)+pi;
holo_phase2 = uint8((rot90(holo_phase, 3)/(2*pi))*255);

imwrite(holo_phase2, )


end