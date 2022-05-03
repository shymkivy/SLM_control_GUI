function f_sg_xyz_button_remove_selected(app)

if size(app.UIImagePhaseTableSelection,1) > 0
    pat_num = app.UIImagePhaseTable.Data.Pattern(app.UIImagePhaseTableSelection(1));
    app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),:) = [];
    num_rows = numel(app.UIImagePhaseTable.Data.X);
    app.UIImagePhaseTable.Data.Idx = (1:num_rows)';
    if num_rows < app.UIImagePhaseTableSelection(1)
        app.UIImagePhaseTableSelection = [];
    end

end



end
