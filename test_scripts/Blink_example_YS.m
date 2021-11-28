% Example usage of Blink_SDK_C.dll
% Meadowlark Optics Spatial Light Modulators
% last updated: April 6 2018


%% Initialize SLM

ops = f_SLM_initialize(ops);


%% create image

if ops.SDK_created == 1
    % Initialize image pointers
    ImageOne = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    ImageTwo = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    WFC = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));
    
    % Generate a blank wavefront correction image, you should load your
    % custom wavefront correction that was shipped with your SLM.
    ops.PixelValue = 0;
    calllib('ImageGen', 'Generate_Solid', WFC, ops.width, ops.height, ops.PixelValue);
    WFC = reshape(WFC.Value, [ops.width,ops.height]);

    %% Generate a fresnel lens
    CenterX = ops.width/2;
    CenterY = ops.height/2;
    Radius = ops.height/2;
    Power = 1;
    cylindrical = true;
    horizontal = false;
    calllib('ImageGen', 'Generate_FresnelLens', ImageOne, ops.width, ops.height, CenterX, CenterY, Radius, Power, cylindrical, horizontal);
    ImageOne = reshape(ImageOne.Value, [ops.width,ops.height]);
    ImageOne = rot90(mod(ImageOne + WFC, 256));
    
    figure; imagesc(ImageOne)
    
    
    %% Generate a blazed grating
    Period = 128;
    Increasing = 1;
    calllib('ImageGen', 'Generate_Grating', ImageTwo, ops.width, ops.height, Period, Increasing, horizontal);
    ImageTwo = reshape(ImageTwo.Value, [ops.width,ops.height]);
    ImageTwo = rot90(mod(ImageTwo + WFC, 256));
    
    figure; imagesc(ImageTwo)
      
    %% Loop between our two images
    for n = 1:5
		%write image returns on DMA complete, ImageWriteComplete returns when the hardware
		%image buffer is ready to receive the next image. Breaking this into two functions is 
		%useful for external triggers. It is safe to apply a trigger when Write_image is complete
		%and it is safe to write a new image when ImageWriteComplete returns
        f_SLM_update(ops, ImageOne);
        pause(1.0) % This is in seconds
        f_SLM_update(ops, ImageTwo);
        pause(1.0) % This is in seconds
    end
    
    
end

%% close SLM
ops = f_SLM_close(ops);



