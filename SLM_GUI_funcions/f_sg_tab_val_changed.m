function f_sg_tab_val_changed(app, event)

% to prevent repeating index
tab_data = app.UIImagePhaseTable.Data;
if strcmpi(tab_data.Properties.VariableNames(event.Indices(2)), 'Idx')
    temp_idx = tab_data.Idx;
    temp_idx(event.Indices(1)) = [];
    current_data = event.NewData;
    is_taken = sum(temp_idx == current_data);
    while is_taken
        current_data = current_data + 1;
        is_taken = sum(temp_idx == current_data);
    end
    tab_data.Idx(event.Indices(1)) = current_data;
end
app.UIImagePhaseTable.Data = tab_data;

end