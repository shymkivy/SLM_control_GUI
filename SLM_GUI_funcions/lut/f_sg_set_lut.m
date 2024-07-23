function f_sg_set_lut(app)

SLM_params = app.SLM_ops.SLM_params_use;

% add field if missing
if ~isfield(SLM_params, 'lut_fname')
    SLM_params.lut_fname = '';
    warning('SLM_params.lut_fname field is missing in default_ops file');
end

lut_found = 0;
if numel(SLM_params.lut_fname) 
    if sum(strcmpi(SLM_params.lut_fname, app.LUTDropDown.Items)) % if lut found
        app.LUTDropDown.Value = SLM_params.lut_fname;
        lut_found = 1;
    end
end

if ~lut_found
    if sum(strcmpi('linear.lut', app.LUTDropDown.Items)) % or if there is linear lut
        SLM_params.lut_fname = 'linear.lut';
        app.LUTDropDown.Value = SLM_params.lut_fname;
        disp('Lut file not found, switched to linear lut')
    else
        error('Indicate a lut file in SLM_params.lut_fname, and add the file to lut directory: %s', SLM_params.lut_dir)
    end
end

app.SLM_ops.SLM_params_use = SLM_params;

end