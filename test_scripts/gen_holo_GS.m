SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink_SDK_all\SDK_1920_4_857';

addpath(SLM_SDK_dir);
addpath('C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_GUI\SLM_GUI_funcions')

if ~libisloaded('ImageGen') 
    loadlibrary('ImageGen.dll', 'ImageGen.h');
end


SLMn = 1920;
SLMm = 1152;
depth = 8;
RGB = 0;

pointer = libpointer('uint8Ptr', zeros(SLMn*SLMm,1));
WFC = libpointer('uint8Ptr', zeros(SLMn*SLMm,1));

% calllib('ImageGen', 'Generate_Solid',...
%             pointer,...
%             SLMn, SLMm,...
%             100); 

calllib('ImageGen', 'Generate_Solid',...
            pointer, WFC,...
            SLMn, SLMm, depth,...
            100, RGB);
        
        
calllib('ImageGen', 'Generate_Stripe',...
            pointer, WFC,...
            SLMn, SLMm, depth,...
            0, 128, 16, RGB);
       
calllib('ImageGen', 'Initialize_HologramGenerator',...
            SLMn, SLMm, depth,...
            50, RGB);
               
calllib('ImageGen', 'Generate_Hologram',...
            pointer, WFC,...
            [51, -70, 30, -57],...
            [33, -47, 12, 92],...
            [0, 0, 0, 0],....
            [1, 1,1, 1],...
            4,...
            0);
        
calllib('ImageGen', 'Destruct_HologramGenerator')        

% calllib('ImageGen', 'Initialize_GerchbergSaxton')   
% 
% calllib('ImageGen', 'GerchbergSaxton',...
%             pointer, WFC,...
%             )   
% 
% calllib('ImageGen', 'Destruct_GerchbergSaxton')   

pupil = f_sg_poiner_to_im(pointer, SLMm, SLMn);

figure; imagesc(pupil)

imE = fftshift(fft2(exp(1i*pupil)));

im1 = imE.*conj(imE);

im2 = abs(imE).^2;

figure; imagesc(im1);

calllib('Blink_SDK_C', 'Create_SDK', ops.bit_depth, ops.slm_resolution, ops.num_boards_found, ops.constructed_okay,...
                    ops.is_nematic_type, ops.RAM_write_enable, ops.use_GPU, ops.max_transients, init_lut_fpath);


ops.bit_depth = 8;
ops.num_boards_found = libpointer('uint32Ptr', 0);
ops.constructed_okay = libpointer('int32Ptr', 0);
ops.is_nematic_type = 1; %  for SLMs built with Nematic Liquid Crystal
ops.RAM_write_enable = 1;
ops.use_GPU = 0;    % this is specific to ODP slms (512) (and imagegen)
ops.max_transients = 10; % this is specific to ODP slms (512)
ops.true_frames = 3;
ops.slm_resolution = 512;
ops.wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
ops.external_Pulse = 0;


%%
init_lut_fpath = libpointer('string'); % null for new bns, only important for old

ops.sdk = calllib('Blink_SDK_C', 'Create_SDK', ops.bit_depth, ops.slm_resolution, ops.num_boards_found, ops.constructed_okay,...
                    ops.is_nematic_type, ops.RAM_write_enable, ops.use_GPU, ops.max_transients, init_lut_fpath);
