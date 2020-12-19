function coord = f_SLM_mpl_get_coords(app, from_where, num)

if strcmp(from_where, 'custom')
    coord.xyzp = [app.XdisplacementEditField.Value,...
                  app.YdisplacementEditField.Value,...
                  app.ZOffsetumEditField.Value*10e-6];

    coord.weight = app.WeightEditField.Value;

    if app.ManualNAcorrectionCheckBox.Value
        coord.NA = app.ManualNAEditField.Value;
    else
        [~, ~, ~, reg1] = f_SLM_get_reg_deets(app, app.CurrentregionDropDown.Value);
        coord.NA = reg1.effective_NA;
    end
    
elseif strcmp(from_where, 'table_selection')
    if ~isempty(app.UIImagePhaseTable.Data)
        coord.xyzp = [app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),4).Variables,...
                      app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),5).Variables,...
                      app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),3).Variables*10e-6];

        coord.weight = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),7).Variables;
        coord.NA = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),6).Variables;
        coord.idx = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),1).Variables;
    else
        coord = [];
    end
elseif strcmp(from_where, 'pattern')
    if ~isempty(app.UIImagePhaseTable.Data)
        plan_idx = app.UIImagePhaseTable.Data(:,strcmpi(app.UIImagePhaseTable.ColumnName, 'pattern')).Variables == num;
        if sum(plan_idx)
            plane_table = app.UIImagePhaseTable.Data(plan_idx,:).Variables;
            coord.xyzp = [plane_table(:,4:5), plane_table(:,3)*10e-6];
            coord.weight = plane_table(:,7);
            coord.NA = plane_table(:,6);
            coord.idx = plane_table(:,1);
        else
            coord = [];
        end
    else
        coord = [];
    end
elseif strcmp(from_where, 'z_plane')
    if ~isempty(app.UIImagePhaseTable.Data)
        plan_idx = app.UIImagePhaseTable.Data(:,strcmpi(app.UIImagePhaseTable.ColumnName, 'z')).Variables == num;
        if sum(plan_idx)
            plane_table = app.UIImagePhaseTable.Data(plan_idx,:).Variables;
            coord.xyzp = [plane_table(:,4:5), plane_table(:,3)*10e-6];
            coord.weight = plane_table(:,7);
            coord.NA = plane_table(:,6);
            coord.idx = plane_table(:,1);
        else
            coord = [];
        end
    else
        coord = [];
    end
elseif strcmp(from_where, 'zero')
    coord.xyzp = [0, 0, 0];
    coord.weight = 1;
    [~, ~, ~, reg1] = f_SLM_get_reg_deets(app, app.CurrentregionDropDown.Value);
    coord.NA = reg1.effective_NA;
end


end