function table_data = f_sg_initialize_tabxyz(app, num_rows)

num_col = numel(app.GUI_ops.table_var_names);

table_data = array2table(zeros(num_rows, num_col));
table_data.Properties.VariableNames = app.GUI_ops.table_var_names;

table_data.Idx = (1:num_rows)';
table_data.Pattern = (1:num_rows)';
table_data.Weight = ones(num_rows,1);
table_data.Power = ones(num_rows,1);
end