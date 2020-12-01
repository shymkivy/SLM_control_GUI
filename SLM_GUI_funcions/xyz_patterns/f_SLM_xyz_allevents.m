function f_SLM_xyz_allevents(src, evt, app)

idx = str2double(src.Label);

if strcmpi(evt.EventName, 'DeletingROI')
    app.UIImagePhaseTable.Data(idx,:) = [];
    %app.UIImagePhaseTable.Data(:,1) = array2table((1:size(app.UIImagePhaseTable.Data,1))');
    for n_cl = 1:size(app.UIImagePhaseTable.Data,1)
        idx2 = app.UIImagePhaseTable.Data(n_cl,1).Variables;
        if idx2 > idx
            app.UIImagePhaseTable.Data(n_cl,1).Variables = idx2 - 1;
        end
    end
    for n_cl = 1:numel(src.Parent.Children)
        if strcmpi(src.Parent.Children(n_cl).Type, 'images.roi.point')
            idx2 = str2double(src.Parent.Children(n_cl).Label);
            if idx2 > idx
                src.Parent.Children(n_cl).Label = num2str(idx2 - 1);
            end
        end
    end
    
elseif strcmpi(evt.EventName, 'ROIMoved')
    if sum(app.UIImagePhaseTable.Data(:,1).Variables == idx)
        coord = round(evt.CurrentPosition(1,1:2)) - 256/2;
        app.UIImagePhaseTable.Data(idx,4:5) = array2table((coord));
    end
end

end