classdef GUIobj < handle
    properties
        height;
        width;
    end
    methods
        function ops = GUIobj(SLMobj)
            ops.height = SLMobj.height;
            ops.width = SLMobj.width;

        end
        function pointer = init_pointer(ops)
            pointer = libpointer('uint8Ptr', zeros(ops.height*ops.width,1));
        end
        function im_out = pointer_to_im(ops, pointer_in)
            holo_image = double(mod(pointer_in.Value, 256))/255*2*pi;
            im_out = reshape(holo_image,ops.width,ops.height)';

        end
        function pointer_out = im_to_pointer(ops, holo_image)
            pointer_out = ops.init_pointer();
            temp_holo = uint8((holo_image/(2*pi))*255);
            pointer_out.value = reshape(temp_holo', [],1);
        end
        function blank_phase_p = generateBlankP(ops)
            blank_phase = zeros(ops.height, ops.width);
            blank_phase_p = ops.im_to_pointer(blank_phase);
        end
        function plot_image(~, image_in)
            figure();
            imagesc(image_in);
        end
        function plot_pointer(ops, pointer_in)
            image_in = ops.pointer_to_im(pointer_in);
            figure();
            imagesc(image_in);
        end
        function blank = generateBlank(ops)
            blank = zeros(ops.height, ops.width);
        end
        function stripes = generateStripes(ops, pixelValOne, pixelValTwo, pixelPerStripe, is_horizontal)
            
            if ~exist('pixelValOne', 'var'); pixelValOne = 0; end
            if ~exist('pixelValTwo', 'var'); pixelValTwo = 1; end
            if ~exist('pixelPerStripe', 'var'); pixelPerStripe = 8; end
            if ~exist('is_horizontal', 'var'); is_horizontal = 0; end
            
            stripes = zeros(ops.height, ops.width);
            if is_horizontal
                for n_pix = 1:ops.height
                    idx1 = rem(ceil(n_pix/pixelPerStripe),2);
                    if idx1
                        stripes(n_pix,:) = pixelValOne;
                    else
                        stripes(n_pix,:) = pixelValTwo;
                    end
                end
            else
                for n_pix = 1:ops.width
                    idx1 = rem(ceil(n_pix/pixelPerStripe),2);
                    if idx1
                        stripes(:,n_pix) = pixelValOne;
                    else
                        stripes(:,n_pix) = pixelValTwo;
                    end
                end
            end
        end
        function pixel_region_idx = generateRegionIndexMask(ops, region_m, region_n)
            % layout is opposite direction of matlab normal
            % |  1  2  3  4 |
            % |  5  6  7  8 |
            % |  9 10 11 12 |
            % | 13 14 15 16 |
            
            region_mask_m = zeros(ops.height, ops.width);
            region_mask_n = zeros(ops.height, ops.width);
            
            for n_col = 1:ops.width
                region_mask_n(:,n_col) = ceil(n_col/ops.width*region_n)-1;
            end
            for n_row = 1:ops.height
                region_mask_m(n_row,:) = ceil(n_row/ops.height*region_m)-1;
            end
            
            pixel_region_idx = region_mask_m*region_n + region_mask_n;
            
            end
    end
end