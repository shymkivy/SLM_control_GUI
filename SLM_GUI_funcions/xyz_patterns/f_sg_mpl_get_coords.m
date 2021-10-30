function coord = f_sg_mpl_get_coords(app, from_where, num)

if strcmp(from_where, 'custom')
    coord.xyzp = [app.XdisplacementEditField.Value,...
                  app.YdisplacementEditField.Value,...
                  app.ZOffsetumEditField.Value*1e-6];

    coord.weight = app.WeightEditField.Value;
       
    if app.ManualNAcorrectionCheckBox.Value
        coord.NA = app.ManualNAEditField.Value;
    else
        [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
        coord.NA = reg1.effective_NA;
    end
    
elseif strcmp(from_where, 'table_selection')
    if ~isempty(app.UIImagePhaseTable.Data)
        
        tab_var = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),:).Variables;
        
        coord.idx = tab_var(1);
        coord.xyzp = [tab_var(3:4), tab_var(5)*1e-6];
        coord.weight = tab_var(6);
        
        [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
        coord.NA = reg1.effective_NA;
    else
        coord = [];
    end
elseif strcmp(from_where, 'pattern')
    if ~isempty(app.UIImagePhaseTable.Data)
        
        tab_var = app.UIImagePhaseTable.Data.Variables; 
        plan_idx = tab_var(:,2) == num;
        
        if sum(plan_idx)
            
            tab_var2 = tab_var(plan_idx,:);
            
            coord.idx = tab_var2(:,1);
            coord.xyzp = [tab_var2(:,3:4), tab_var2(:,5)*1e-6];
            coord.weight = tab_var2(:,6);
            
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