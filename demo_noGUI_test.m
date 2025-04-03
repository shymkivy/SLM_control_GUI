
gui_dir = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_GUI';
addpath(genpath([gui_dir '\SLM_GUI_funcions']));

ops = f_SLM_default_ops(gui_dir);

ops.SLM_type = 'BNS1920'; % 'BNS1920', 'BNS512', 'BNS512OD' Which SLM name from default params to use

SLM_params = ops.SLM_params(strcmpi({ops.SLM_params.SLM_name}, ops.SLM_type));
%SLM_params = ops1.SLM_params(3);

%%
utilObj = UtilObj(ops);
utilObj.init_dir()


%%
slmObj = sdk4857(SLM_params);
slmObj.init();

%%
guiObj = GUIobj(slmObj);

igObj = imGen4857(ops.imageGen_dir);
igObj.init(slmObj.height, slmObj.width);

igObj.load_WFC_image([SLM_params.lut_dir, '\', SLM_params.WFC_fname]);
guiObj.plot_pointer(igObj.WFC_ptr)

igObj2 = imGen4857(ops.imageGen_dir);
igObj2.init(slmObj.height, slmObj.width);

im_p22 = igObj2.generateStripe(0, 20, 20, 0);

figure();
imagesc(guiObj.pointer_to_im(im_p2) - guiObj.pointer_to_im(im_p22) - guiObj.pointer_to_im(igObj.WFC_ptr))

figure()
imagesc(guiObj.pointer_to_im(im_p22))

figure()
imagesc(guiObj.pointer_to_im(im_p2))

WFC1 = guiObj.pointer_to_im(igObj.WFC_ptr)-pi;

figure()
imagesc(WFC1)

WFC2 = angle(exp(1i * (WFC1)));

figure();
imagesc(WFC2)

figure();
imagesc(WFC1 - WFC2)


% adding two phases, static correction to whatever
phase_sum = angle(exp(1i * (guiObj.pointer_to_im(igObj.WFC_ptr)-pi)) .* exp(1i * (guiObj.pointer_to_im(im_p22))))+pi;

phase_sum = angle(exp(1i * (guiObj.pointer_to_im(im_p22))));

figure()
imagesc(phase_sum)

figure()
imagesc(phase_sum - guiObj.pointer_to_im(im_p22))






%% image
%im_p = guiObj.init_pointer();

im_p = guiObj.generateBlankP();
im_p2 = igObj.generateStripe(0, 20, 20, 0);
im_p3 = igObj.generateCheckerboard(0, 128, 20);
im_p4 = igObj.generateRandom();
im_p5 = igObj.generateSolid(0);


%% plot
guiObj.plot_pointer(im_p2)

%%
slmObj.image_write(im_p);

%%
slmObj.close()

igObj.close();

%%




%%



