function f_sg_gui_startup(app, GUI_dir)

%% add all paths inside functions folder

%addpath(genpath([app.SLM_ops.GUI_dir '\SLM_GUI_funcions']));
% list1 = dir([app.SLM_ops.GUI_dir '\SLM_GUI_funcions']);
% for n_ls = 1:numel(list1)
%     if ~strcmpi(list1(n_ls).name, '..') && ~strcmpi(list1(n_ls).name, '.')
%         if list1(n_ls).isdir
%             addpath([app.SLM_ops.GUI_dir '\SLM_GUI_funcions\' list1(n_ls).name]);
%         end
%     end
% end

%%
app.SLM_ops = f_SLM_default_ops(GUI_dir);

%% create calibration dirs
ops = app.SLM_ops;

for dir1 = {ops.lut_dir, ops.xyz_calibration_dir, ops.AO_correction_dir, ops.point_weight_correction_dir}
    if ~exist(dir1{1}, 'dir')
        fprintf('Creating dir: %s\n', dir1{1});
        mkdir(dir1{1});
    end
end

%% load lut lists
f_sg_load_default_ops(app);
f_sg_load_calibration(app);
f_sg_reg_update(app);

app.SLM_ops = f_SLM_initialize(app.SLM_ops);
if app.SLM_ops.sdkObj.SDK_created
    app.ActivateSLMButton.Value = 1;
    app.ActivateSLMLamp.Color = [0.00,1.00,0.00];
end
f_sg_initialize_GUI_params(app);

%f_sg_ops_load(app);

end