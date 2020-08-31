% Example usage of Blink_SDK_C.dll
% Meadowlark Optics Spatial Light Modulators
% last updated: April 6 2018

%% Initialize SLM

ops = f_SLM_initialize_ops_YS();
ops = f_SLM_initialize_YS(ops);

 %%   
if ops.SDK_created == 1    
    NumDataPoints = 256;
    NumRegions = 1;
    
    %allocate arrays for our images
    Image = libpointer('uint8Ptr', zeros(ops.width*ops.height,1));

    % Create an array to hold measurements from the analog input (AI) board
    AI_Intensities = zeros(NumDataPoints,2);
    
    % Generate a blank wavefront correction image, you should load your
    % custom wavefront correction that was shipped with your SLM.
    PixelValue = 0;
    calllib('ImageGen', 'Generate_Solid', Image, ops.width, ops.height, PixelValue);
    
    f_SLM_update_YS(ops, Image);
	
    PixelsPerStripe = 8;
    %loop through each region
    for Region = 0:(NumRegions-1)
      
        AI_Index = 1;
        %loop through each graylevel
        for Gray = 0:(NumDataPoints-1)
            %Generate the stripe pattern and mask out current region
            calllib('ImageGen', 'Generate_Stripe', Image, ops.width, ops.height, PixelValue, Gray, PixelsPerStripe);
            calllib('ImageGen', 'Mask_Image', Image, ops.width, ops.height, Region, NumRegions);
            
            %write the image
            f_SLM_update_YS(ops, Image);
            
            %let the SLM settle for 10 ms
            pause(0.01);
            
            %YOU FILL IN HERE...FIRST: read from your specific AI board, note it might help to clean up noise to average several readings
            %SECOND: store the measurement in your AI_Intensities array
            AI_Intensities(AI_Index, 1) = Gray; %This is the varable graylevel you wrote to collect this data point
            AI_Intensities(AI_Index, 2) = 0; % HERE YOU NEED TO REPLACE 0 with YOUR MEASURED VALUE FROM YOUR ANALOG INPUT BOARD
 
            AI_Index = AI_Index + 1;
        
        end
        
        % dump the AI measurements to a csv file
        filename = ['Raw' num2str(Region) '.csv'];
        csvwrite(filename, AI_Intensities);  
    end
end
     
%% close SLM
ops = f_SLM_close_YS(ops);