function coord = f_sg_mpl_get_coords(app, from_where, num)

if strcmp(from_where, 'custom')
    X_disp = f_str_to_array(app.XdisplacementEditField.Value);
    Y_disp = f_str_to_array(app.YdisplacementEditField.Value);
    Z_disp = f_str_to_array(app.ZoffsetumEditField.Value);
    W = f_str_to_array(app.WeightEditField.Value);
    
    max_len = max([numel(X_disp), numel(Y_disp), numel(Z_disp), numel(W)]);
    
    if max_len > 1
        if numel(X_disp) == 1
            X_disp = ones(max_len,1)*X_disp;
        end
        if numel(Y_disp) == 1
            Y_disp = ones(max_len,1)*Y_disp;
        end
        if numel(Z_disp) == 1
            Z_disp = ones(max_len,1)*Z_disp;
        end
        if numel(W) == 1
            W = ones(max_len,1)*W;
        end
    end
    
    min_len = min([numel(X_disp), numel(Y_disp), numel(Z_disp), numel(W)]);
    
    if min_len < max_len
        X_disp = X_disp(1:min_len);
        Y_disp = Y_disp(1:min_len);
        Z_disp = Z_disp(1:min_len);
        W = W(1:min_len);
    end
    
    coord.xyzp = [X_disp,...
                  Y_disp,...
                  Z_disp];

    coord.weight = W;
    coord.weight_set = W;

elseif strcmp(from_where, 'table_selection')
    if ~isempty(app.UIImagePhaseTable.Data)
        
        tab_data = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),:);
        
        coord.idx = tab_data.Idx;
        coord.xyzp = [tab_data.X, tab_data.Y, tab_data.Z];
        coord.weight = tab_data.W_comp;
        coord.weight_set = tab_data.W_set;

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
            coord.weight = tab_data2.W_comp;
            coord.weight_set = tab_data.W_set;
            
        else
            coord = [];
        end
    else
        coord = [];
    end
elseif strcmp(from_where, 'zero')
    coord.xyzp = [0, 0, 0];
    coord.weight = 1;
    coord.weight_set = 1;
end


end