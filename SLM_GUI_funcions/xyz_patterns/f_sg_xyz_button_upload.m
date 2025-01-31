function f_sg_xyz_button_upload(app, upload_type)

%% get coords
if strcmpi(upload_type, 'custom')
    coord = f_sg_get_coords(app, upload_type);
elseif strcmpi(upload_type, 'table_selection')
    if size(app.UIImagePhaseTableSelection,1) > 0
        coord = f_sg_get_coords(app, upload_type);
    else
        coord = [];
    end
elseif strcmpi(upload_type, 'pattern')
    %coord = f_sg_get_coords(app, upload_type, app.PatternSpinner.Value);
    if size(app.UIImagePhaseTableSelection,1) > 0
        coord0 = f_sg_get_coords(app, 'table_selection');
        coord = f_sg_get_coords(app, 'pattern', coord0.pattern);
    else
        coord = [];
        disp('Not uploaded, Select a pattern first')
    end
end

%% uppload coord
f_sg_xyz_upload_coord(app, coord);

end