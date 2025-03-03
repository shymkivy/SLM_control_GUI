function f_sg_pp_add_dir(app)

selpath = uigetdir(app.imagedirEditField.Value, 'Open directory with 2p images');

path1 = f_clean_path(selpath);

app.imagedirEditField.Value = path1;
app.app_main.SLM_ops.pattern_editor_dir = path1;

end