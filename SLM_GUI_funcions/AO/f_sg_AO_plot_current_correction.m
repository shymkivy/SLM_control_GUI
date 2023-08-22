function f_sg_AO_plot_current_correction(app)

if isfield(app.GUI_buffer, 'current_AO_phase')
    AO_phase = app.GUI_buffer.current_AO_phase;
    if ~isempty(AO_phase)
        reg_tag = ['; ' app.GUI_buffer.current_region.reg_name];
        coord1 = app.GUI_buffer.current_SLM_coord;
        z_all = unique(coord1.xyzp(:,3));
        num_z = numel(z_all);
        for n_z = 1:num_z
            f_sg_view_hologram_phase(app, AO_phase(:,:,n_z));
            title(sprintf('Current AO wavefront; %s; %dum', reg_tag, z_all(n_z)));
        end
    else
        disp('No AO uploaded')
    end
end

end