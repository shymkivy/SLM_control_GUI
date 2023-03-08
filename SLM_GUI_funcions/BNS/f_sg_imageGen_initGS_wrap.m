function f_sg_imageGen_initGS_wrap(app, reg1)

app.SLM_ops = f_SLM_BNS_imageGen_initGS(app.SLM_ops, reg1, app.GSnumiterationsEditField.Value);

if app.SLM_ops.ImageGen.new_ver
    app.ImageGenverEditField.Value = '4, new';
else
    app.ImageGenverEditField.Value = '3, old';
end


end