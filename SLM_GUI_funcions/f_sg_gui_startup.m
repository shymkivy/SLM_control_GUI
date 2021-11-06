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

%% create calibration dirs
ops = app.SLM_ops;

% LUT dir
if ~exist(ops.lut_dir, 'dir')
    mkdir(ops.lut_dir)
end

% xyz calibration
if ~exist(ops.xyz_calibration_dir, 'dir')
    mkdir(ops.xyz_calibration_dir)
end

if ~exist(ops.AO_correction_dir, 'dir')
    mkdir(ops.AO_correction_dir)
end

%% load lut lists
f_sg_load_default_ops(app);
f_sg_load_calibration(app);
f_sg_reg_update(app);

app.SLM_ops = f_SLM_initialize(app.SLM_ops);
app.ActivateSLMButton.Value = 1;
app.ActivateSLMLamp.Color = [0.00,1.00,0.00];

f_sg_initialize_GUI_params(app);

f_sg_ops_load(app);

end