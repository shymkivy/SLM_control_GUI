function coord = f_SLM_mpl_get_coords(app, from_where, num)

if strcmp(from_where, 'custom')
    coord.xyzp = [app.XdisplacementEditField.Value,...
                  app.YdisplacementEditField.Value,...
                  app.ZOffsetumEditField.Value*10e-6];

    coord.weight = app.WeightEditField.Value;

    if app.ManualNAcorrectionCheckBox.Value
        coord.NA = app.ManualNAEditField.Value;
    else
        coord.NA = app.ObjectiveNAEditField.Value;
    end
    
elseif strcmp(from_where, 'table_selection')
    if ~isempty(app.UIImagePhaseTable.Data)
        coord.xyzp = [app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),3).Variables,...
                      app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),4).Variables,...
                      app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),2).Variables*10e-6];

        coord.weight = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),6).Variables;
        coord.NA = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),5).Variables;
    else
        coord = [];
    end
elseif strcmp(from_where, 'pattern')
    if ~isempty(app.UIImagePhaseTable.Data)
        plan_idx = app.UIImagePhaseTable.Data(:,1).Variables == num;
        if sum(plan_idx)
            plane_table = app.UIImagePhaseTable.Data(plan_idx,:).Variables;
            coord.xyzp = [plane_table(:,3:4), plane_table(:,2)*10e-6];
            coord.weight = plane_table(:,6);
            coord.NA = plane_table(:,5);
        else
            coord = [];
        end
    else
        coord = [];
    end
elseif strcmp(from_where, 'z_plane')
    if ~isempty(app.UIImagePhaseTable.Data)
        plan_idx = app.UIImagePhaseTable.Data(:,2).Variables == num;
        if sum(plan_idx)
            plane_table = app.UIImagePhaseTable.Data(plan_idx,:).Variables;
            coord.xyzp = [plane_table(:,3:4), plane_table(:,2)*10e-6];
            coord.weight = plane_table(:,6);
            coord.NA = plane_table(:,5);
        else
            coord = [];
        end
    else
        coord = [];
    end
elseif strcmp(from_where, 'zero')
    coord.xyzp = [0, 0, 0];
    coord.weight = 1;
    coord.NA = app.ObjectiveNAEditField.Value;
end


end