function f_sg_xyz_button_remove_selected(app)

if size(app.UIImagePhaseTableSelection,1) > 0
    
    tab_data2 = app.UIImagePhaseTable.Data;
    %pat_num = app.UIImagePhaseTable.Data.Pattern(app.UIImagePhaseTableSelection(1));
    tab_data2(app.UIImagePhaseTableSelection(1),:) = [];
    
    %bd_idx = 999;
    %bd_idx2 = tab_data2.Idx == bd_idx;
    
    %tab_data3 = tab_data2(~bd_idx2,:);
    
    num_rows = numel(tab_data2.Idx);
%     tab_data3.Idx = (1:num_rows)';
%   
    app.UIImagePhaseTable.Data = tab_data2;

    if num_rows < app.UIImagePhaseTableSelection(1)
        app.UIImagePhaseTableSelection = [];
    end
    
    %tab_data2(~bd_idx2,:) = tab_data3;
    
end


 
end
