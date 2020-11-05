function f_SLM_gh_blazed(app)

% get roi
[m, n] = f_SLM_gh_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

pointer = libpointer('uint8Ptr', zeros(SLMn*SLMm,1));

calllib('ImageGen', 'Generate_Grating',...
        pointer,...
        SLMn, SLMm,...
        app.BlazPeriodEditField.Value,...
        app.BlazIncreasingCheckBox.Value,...
        app.BlazHorizontalCheckBox.Value);

f_SLM_holo_to_im(app, pointer, SLMm, SLMn);
            
end