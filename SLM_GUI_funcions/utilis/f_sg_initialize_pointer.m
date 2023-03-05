function pointer = f_sg_initialize_pointer(app)
    pointer = libpointer('uint8Ptr', zeros(app.SLM_ops.width*app.SLM_ops.height,1));

    % old iagegen
%     calllib('ImageGen', 'Generate_Solid', pointer, app.SLM_ops.width, app.SLM_ops.height,...
%                 app.BlankPixelValueEditField.Value);
    
    % new imagegen
    % IMAGE_GEN_API void Generate_Solid(unsigned char* Array, unsigned char* WFC, int width, int height, int depth, int PixelVal, int RGB);
end