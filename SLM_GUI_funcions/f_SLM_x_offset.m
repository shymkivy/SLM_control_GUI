function f_SLM_x_offset(app)

app.SLM_Image = app.SLM_X_offset_im;
f_SLM_upload_image_to_SLM(app);    
disp('SLM X offset uploaded');

end