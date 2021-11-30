function f_sg_AO_plot_current_correction(app)

AO_phase = [];
reg_tag = '';
if isfield(app.GUI_buffer, 'current_AO_phase')
    if isfield(app.GUI_buffer.current_SLM_coord, 'weight')
        weight = app.GUI_buffer.current_SLM_coord.weight;
        AO_phase = angle(sum(exp(1i*app.GUI_buffer.current_AO_phase).*reshape(weight, [1 1 numel(weight)]),3));
        if isfield(app.GUI_buffer, 'current_region')
            reg_tag = ['; ' app.GUI_buffer.current_region.reg_name];
        end
    end
end

f_sg_view_hologram_phase(app, AO_phase);
title(['Current AO wavefront' reg_tag]);

end