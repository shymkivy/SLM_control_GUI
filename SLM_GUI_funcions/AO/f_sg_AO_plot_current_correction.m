function f_sg_AO_plot_current_correction(app)

if isfield(app.GUI_buffer, 'current_AO_phase')
    weight = app.GUI_buffer.current_SLM_coord.weight;
    AO_phase_superpos = angle(sum(exp(1i*app.GUI_buffer.current_AO_phase).*reshape(weight, [1 1 numel(weight)]),3));
    f_sg_view_hologram_phase(app, AO_phase_superpos);
    if isfield(app.GUI_buffer, 'current_region')
        reg_tag = ['; ' app.GUI_buffer.current_region.reg_name];
    else
        reg_tag = '';
    end
    title(['Current AO wavefront' reg_tag]);
    
end

end