
gui_dir = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_GUI';
addpath(genpath([gui_dir '\SLM_GUI_funcions']));

ops1 = f_SLM_default_ops(gui_dir);

ops.SLM_type = 'BNS1920'; % 'BNS1920', 'BNS512', 'BNS512OD' Which SLM name from default params to use

SLM_params = ops.SLM_params(strcmpi({ops.SLM_params.SLM_name}, ops.SLM_type));
%SLM_params = ops1.SLM_params(3);

%%
utilObj = UtilObj(ops1);
utilObj.init_dir()


%%
slmObj = sdk4851(SLM_params);
slmObj.init();

%%
guiObj = GUIobj(slmObj);

igObj = imGen4(ops.imageGen_dir);
igObj.init(slmObj.height, slmObj.width);

%% image
im_p = guiObj.init_pointer();

im_p = guiObj.generateBlankP();
im_p = igObj.generateStripe(im_p);
im_p = igObj.generateCheckerboard(im_p);
im_p = igObj.generateRandom(im_p);


%% plot
guiObj.plot_pointer(im_p)

guiObj.generateBlank()
%%
slmObj.image_write(im_p);

%%
slmObj.close()

igObj.close();

%%




%%



