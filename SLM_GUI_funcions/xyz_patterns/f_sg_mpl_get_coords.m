function coord = f_sg_mpl_get_coords(app, from_where, num)

if strcmp(from_where, 'custom')
    coord.xyzp = [app.XdisplacementEditField.Value,...
                  app.YdisplacementEditField.Value,...
                  app.ZOffsetumEditField.Value];

    coord.weight = app.WeightEditField.Value;
       
    if app.ManualNAcorrectionCheckBox.Value
        coord.NA = app.ManualNAEditField.Value;
    else
        [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
        coord.NA = reg1.effective_NA;
    end
    
elseif strcmp(from_where, 'table_selection')
    if ~isempty(app.UIImagePhaseTable.Data)
        
        tab_data = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),:);
        
        coord.idx = tab_data.Idx;
        coord.xyzp = [tab_data.X, tab_data.Y, tab_data.Z];
        coord.weight = tab_data.Weight;
        
        [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
        coord.NA = reg1.effective_NA;
    else
        coord = [];
    end
elseif strcmp(from_where, 'pattern')
    if ~isempty(app.UIImagePhaseTable.Data)
        
        tab_data = app.UIImagePhaseTable.Data; 
        plan_idx = tab_data.Pattern == num;
        
        if sum(plan_idx)
            
            tab_data2 = tab_data(plan_idx,:);
            
            coord.idx = tab_data2.Idx;
            coord.xyzp = [tab_data2.X, tab_data2.Y, tab_data2.Z];
            coord.weight = tab_data2.Weight;

            [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
            coord.NA = reg1.effective_NA;
            
        else
            coord = [];
        end
    else
        coord = [];
    end
elseif strcmp(from_where, 'zero')
    coord.xyzp = [0, 0, 0];
    coord.weight = 1;
    [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    coord.NA = reg1.effective_NA;
end


end