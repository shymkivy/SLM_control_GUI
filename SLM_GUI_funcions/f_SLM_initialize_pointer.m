function pointer = f_SLM_initialize_pointer(app)
    pointer = libpointer('uint8Ptr', zeros(app.SLM_ops.width*app.SLM_ops.height,1));
    calllib('ImageGen', 'Generate_Solid', pointer, app.SLM_ops.width, app.SLM_ops.height,...
                app.BlankPixelValueEditField.Value);
end