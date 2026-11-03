classdef imGen4857 < handle
    properties
        sdk_dir = '';
        version = '4857';
        loaded = 0;

        height;
        width;
        WFC;            % uint8 column (height*width), row-major; pointer made per call
        bit_depth = 8;
        RGB = 0;

        HG;
        HGinitiated = 0;
        num_iter = 50;
        gen_val;
    end
    methods
        %im_funct = libfunctions('ImageGen');
        function ops = imGen4857(imageGen_dir)
            ops.sdk_dir = imageGen_dir;

            % This loads the image generation functions
            if exist([ops.sdk_dir '\ImageGen.dll'], 'file')
                if ~libisloaded('ImageGen')
                    fprintf('Loading ImageGen 4857...');
                    ops.loaded = 1;
                    loadlibrary([ops.sdk_dir '\ImageGen.dll'], [ops.sdk_dir '\ImageGen.h']);
                    fprintf('Done\n');
                end
            else
                error('image gen dll does not exist in %s', ops.sdk_dir)
            end

        end
        %%
        function ops = init(ops, height, width, WFC, bit_depth, RGB)

            ops.height = height;
            ops.width = width;

            if exist('WFC', 'var') && ~isempty(WFC)
                if isequal(size(WFC), [height, width])
                    WFC = reshape(WFC', [], 1);
                end
                ops.WFC = uint8(WFC(:));
            else
                ops.WFC = zeros(height*width, 1, 'uint8');
            end
            
            if exist('bit_depth', 'var')
                ops.bit_depth = bit_depth;
            end

            if exist('RGB', 'var')
                ops.RGB = RGB;
            end
        end
        %%
        
        function close(ops)
            if ops.HGinitiated
                ops.destructHologramGenerator();
                ops.HGinitiated = 0;
                disp('Destructed ImageGen HG');
            end
            if libisloaded('ImageGen')
                disp('Unloading ImageGen')
                ops.loaded = 0;
                unloadlibrary('ImageGen');
            end
        end
        function pointer = init_pointer(ops)
            pointer = libpointer('uint8Ptr', zeros(ops.height*ops.width,1));
        end
        function p = wfc_pointer(ops)
            p = libpointer('uint8Ptr', ops.WFC);
        end
        function load_WFC_image(ops, path1)
            WFC_im1 = imread(path1);
            ops.WFC = uint8(reshape(WFC_im1', [],1));
        end
        function pointer = generateStripe(ops, pixelValOne, pixelValTwo, pixelPerStripe, horizontal)
            pointer = ops.init_pointer();
            
            if ~horizontal
                calllib('ImageGen', 'Generate_Stripe', pointer, ops.wfc_pointer(), ops.width, ops.height, ops.bit_depth,...
                    pixelValOne, pixelValTwo, pixelPerStripe,...
                    ops.RGB);
            else
                calllib('ImageGen', 'Generate_Stripe', pointer, ops.wfc_pointer(), ops.height, ops.width, ops.bit_depth,...
                    pixelValOne, pixelValTwo, pixelPerStripe,...
                    ops.RGB);
                val2 = reshape(pointer.Value, ops.width, ops.height)';
                pointer.Value = reshape(val2, [],1);
            end
        end
        function pointer = generateCheckerboard(ops, pixelValOne, pixelValTwo, pixelPerCheck)
            pointer = ops.init_pointer();

            calllib('ImageGen', 'Generate_Checkerboard', pointer, ops.wfc_pointer(), ops.width, ops.height, ops.bit_depth,...
                pixelValOne, pixelValTwo, pixelPerCheck,...
                ops.RGB);
        end
        function pointer = generateSolid(ops, PixelVal)
            
            pointer = ops.init_pointer();

            calllib('ImageGen', 'Generate_Solid', pointer, ops.wfc_pointer(), ops.width, ops.height, ops.bit_depth,...
                PixelVal,...
                ops.RGB);
        end
        function pointer = generateRandom(ops)
            pointer = ops.init_pointer();

            calllib('ImageGen', 'Generate_Random', pointer, ops.wfc_pointer(), ops.width, ops.height, ops.bit_depth,...
                ops.RGB);
        end
        function pointer = generateGrating(ops, Period, increasing, horizontal)
            pointer = ops.init_pointer();

            calllib('ImageGen', 'Generate_Grating', pointer, ops.wfc_pointer(), ops.width, ops.height, ops.bit_depth,...
                Period, increasing, horizontal,...
                ops.RGB);
        end
        function pointer = generateFresnel(ops, CenterX, CenterY, Radius, power, cylindrical, horizontal)
            pointer = ops.init_pointer();

            calllib('ImageGen', 'Generate_FresnelLens', pointer, ops.wfc_pointer(), ops.width, ops.height, ops.bit_depth,...
                CenterX, CenterY, Radius, power, cylindrical, horizontal,...
                ops.RGB);
        end
        function pointer = generateZernike(ops, CenterX, CenterY, Radius, Piston,...
                TiltX, TiltY, Power,...
                AstigX, AstigY, ComaX, ComaY, PrimarySpherical,...
                TrefoilX, TrefoilY,...
                SecondaryAstigX, SecondaryAstigY,...
                SecondaryComaX, SecondaryComaY, SecondarySpherical,...
                TetrafoilX, TetrafoilY, TertiarySpherical, QuaternarySpherical)
            
            pointer = ops.init_pointer();

            calllib('ImageGen', 'Generate_Zernike', pointer, ops.wfc_pointer(), ops.width, ops.height, ops.bit_depth,...
                CenterX, CenterY, Radius, Piston,...
                TiltX, TiltY, Power,...
                AstigX, AstigY, ComaX, ComaY, PrimarySpherical,...
                TrefoilX, TrefoilY,...
                SecondaryAstigX, SecondaryAstigY,...
                SecondaryComaX, SecondaryComaY, SecondarySpherical,...
                TetrafoilX, TetrafoilY, TertiarySpherical, QuaternarySpherical,...
                ops.RGB);
        end
        function initHologramGenerator(ops, num_iter)
            if ~exist('num_iter', 'var'); num_iter = ops.num_iter; end

            ops.HG = calllib('ImageGen', 'Initialize_HologramGenerator',...
                ops.width, ops.height, ops.bit_depth, num_iter, ops.RGB);
            if ~ops.HG
                fprintf('Hologram generator init failed\n');
            else
                ops.HGinitiated = 1;
            end   
        end
        function destructHologramGenerator(~)
            calllib('ImageGen', 'Destruct_HologramGenerator');
        end
        function pointer = generateHologram(ops, x_spots, y_spots, z_spots, I_spots, n_spots)
            pointer = ops.init_pointer();

            ops.gen_val = calllib('ImageGen', 'Generate_Hologram',...
                pointer, ops.wfc_pointer(),...
                x_spots, y_spots, z_spots,....
                I_spots, n_spots,...
                0);
        end
    end
end