function f_sg_initialize_imageGen(app)

if ~libisloaded('ImageGen') 
    loadlibrary([app.SLM_ops.imageGen_dir, '\ImageGen.dll'], [app.SLM_ops.imageGen_dir, '\ImageGen.h']);
    
    im_funct = libfunctions('ImageGen');
    if sum(strcmpi(im_funct, 'CalculateAffinePolynomials'))
        app.SLM_ops.imageGen_newver = 1;
        app.ImageGenverEditField.Value = '4, new';
    else
        app.SLM_ops.imageGen_newver = 0;
        app.ImageGenverEditField.Value = '3, old';
    end
    
end

end