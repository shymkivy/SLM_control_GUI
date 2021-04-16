function f_sg_gui_startup(app)

%% add all paths inside functions folder
list1 = dir([app.SLM_ops.GUI_dir '\SLM_GUI_funcions']);
for n_ls = 1:numel(list1)
    if ~strcmpi(list1(n_ls).name, '..') && ~strcmpi(list1(n_ls).name, '.')
        if list1(n_ls).isdir
            addpath([app.SLM_ops.GUI_dir '\SLM_GUI_funcions\' list1(n_ls).name]);
        end
    end
end

%%
f_SLM_GUI_default_ops(app);
f_sg_load_calibration(app);

app.SLM_ops = f_SLM_BNS_initialize(app.SLM_ops);
app.ActivateSLMButton.Value = 1;
app.ActivateSLMLamp.Color = [0.00,1.00,0.00];

f_sg_initialize_GUI_params(app);

f_sg_ops_load(app);

end