function coord = f_sg_get_coords(app, from_where, num)

if strcmp(from_where, 'custom')
    X_disp = f_str_to_array(app.XdisplacementEditField.Value);
    Y_disp = f_str_to_array(app.YdisplacementEditField.Value);
    Z_disp = f_str_to_array(app.ZoffsetumEditField.Value);
    I_targ = f_str_to_array(app.IntensitytargetEditField.Value);
    W_est = f_str_to_array(app.WeightEditField.Value);

    max_len = max([numel(X_disp), numel(Y_disp), numel(Z_disp), numel(I_targ), numel(W_est)]);
    
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
        if numel(I_targ) == 1
            I_targ = ones(max_len,1)*I_targ;
        end
        if numel(W_est) == 1
            W_est = ones(max_len,1)*W_est;
        end
    end
    
    min_len = min([numel(X_disp), numel(Y_disp), numel(Z_disp), numel(I_targ), numel(W_est)]);
    
    if min_len < max_len
        X_disp = X_disp(1:min_len);
        Y_disp = Y_disp(1:min_len);
        Z_disp = Z_disp(1:min_len);
        I_targ = I_targ(1:min_len);
        W_est = W_est(1:W_est);
    end
    
    coord.xyzp = [X_disp,...
                  Y_disp,...
                  Z_disp];

    coord.I_targ = I_targ;
    coord.W_est = W_est;
    
    if app.I_targI22PCheckBox.Value
        coord.I_targ1P = sqrt(coord.I_targ);
    else
        coord.I_targ1P = coord.I_targ;
    end

else
    if strcmp(from_where, 'table_selection')
        if ~isempty(app.UIImagePhaseTable.Data)
            
            tab_data = app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),:);
            
            coord.idx = tab_data.Idx;
            coord.xyzp = [tab_data.X, tab_data.Y, tab_data.Z];
            coord.I_targ = tab_data.I_targ;
            coord.pattern = tab_data.Pattern;
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
                coord.I_targ = tab_data2.I_targ;
                coord.pattern = tab_data2.Pattern;
            else
                coord = [];
            end
        else
            coord = [];
        end
    elseif strcmp(from_where, 'zero')
        coord.xyzp = [0, 0, 0];
        coord.I_targ = 1;
    end
    
    if app.I_targI22PCheckBox.Value
        coord.I_targ1P = sqrt(coord.I_targ);
    else
        coord.I_targ1P = coord.I_targ;
    end
    coord.W_est = sqrt(coord.I_targ1P);
end



end