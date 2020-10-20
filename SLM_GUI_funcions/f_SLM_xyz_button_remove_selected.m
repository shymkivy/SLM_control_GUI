function f_SLM_xyz_button_remove_selected(app)

if size(app.UIImagePhaseTableSelection,1) > 0
    app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),:) = [];
    if size(app.UIImagePhaseTable.Data,1) < app.UIImagePhaseTableSelection(1)
        app.UIImagePhaseTableSelection = [];
    end
end

end
