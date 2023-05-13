function f_sg_AO_start_optimization(app)

if app.StartoptimizationButton.Value
    
    AO_temp = [];
    if app.ContinuescanCheckBox.Value
        if isfield(app.GUI_buffer, 'ao_temp')
            if ~isempty(app.GUI_buffer.ao_temp)
                AO_temp = app.GUI_buffer.ao_temp;
            end
        end
    end
    
    f_sg_AO_scan_optimization(app, AO_temp);
    
    app.StartoptimizationButton.Value = 0;
    
end
    
end