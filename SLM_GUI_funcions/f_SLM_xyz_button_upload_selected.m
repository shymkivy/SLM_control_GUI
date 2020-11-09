function f_SLM_xyz_button_upload_selected(app)

if size(app.UIImagePhaseTableSelection,1) > 0
    coord = f_SLM_mpl_get_coords(app, 'table_selection');
    
    app.current_SLM_coord = coord;
    app.UITablecurrentcoord.Data = app.current_SLM_coord.xyzp;
    
    % get region
    [m_idx, n_idx] = f_SLM_gh_get_regmn(app);
    SLMm = sum(m_idx);
    SLMn = sum(n_idx);

    % make im;
    holo_image = app.SLM_blank_im;
    holo_image(m_idx,n_idx) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
    
    app.SLM_Image =  holo_image; 
    f_SLM_upload_image_to_SLM(app);
end

end