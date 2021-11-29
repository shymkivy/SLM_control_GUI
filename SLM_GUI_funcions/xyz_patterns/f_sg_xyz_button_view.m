function f_sg_xyz_button_view(app, view_source, view_out)

%% get coords
if strcmpi(view_source, 'custom')
    coord = f_sg_mpl_get_coords(app, view_source);
elseif strcmpi(view_source, 'table_selection')
    if size(app.UIImagePhaseTableSelection,1) > 0
        coord = f_sg_mpl_get_coords(app, view_source);
    else
        coord = [];
    end
elseif strcmpi(view_source, 'pattern')
    coord = f_sg_mpl_get_coords(app, view_source, app.PatternSpinner.Value);
end

%% gen image and view
if ~isempty(coord)
    [m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    holo_image = f_sg_xyz_gen_holo(app, coord, reg1);

    if strcmpi(view_out, 'phase')
        f_sg_view_hologram_phase(app, holo_image);
        title(sprintf('%s defocus %.1f um', view_source, app.ZOffsetumEditField.Value));
    elseif strcmpi(view_out, 'fft')
        f_sg_view_hologram_fft(app, holo_image(m_idx, n_idx), app.fftdefocusumEditField.Value);
        title(sprintf('%s PSF at %.1f um', view_source, app.fftdefocusumEditField.Value));
    end
end

end