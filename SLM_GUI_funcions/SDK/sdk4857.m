classdef sdk4857 < handle
    properties
        varsion = '4857'
        is_OD = 0;

        SLM_SDK_dir = '';
        bit_depth = 12; % 512 is 8, 1920 is 12
        num_boards_found = libpointer('uint32Ptr', 0);
        constructed_okay = libpointer('int32Ptr', 0);
        is_nematic_type = 1;
        RAM_write_enable = 1;
        max_transients = 10; % this is specific to ODP slms (512)
        wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
        external_Pulse = 0; % same as output_pulse_image_flip?
        timeout_ms = 5000;
        flip_immediate = 0;
        output_pulse_image_refresh = 0;
        true_frames = 3;
        use_GPU = 0;    % this is specific to ODP slms (512)

        init_lut_fpath = libpointer('string'); % null for new bns, only important for old
        lut_path = '';

        SDK_created = 0;
        board_number;
        height;
        width;

        val_complete;
    end
    methods
        function ops = sdk4857(SLM_ops)
            if ~isfield(SLM_ops, 'SLM_SDK_dir') || isempty(SLM_ops.SLM_SDK_dir)
                error('Add proper "SLM_SDK_dir" field to ops');
            end

            ops.SLM_SDK_dir = SLM_ops.SLM_SDK_dir;
            ops.is_OD = SLM_ops.is_OD;

            if ops.is_OD
                ops.use_GPU = 1;    % this is specific to ODP slms (512) (and imagegen)
            end

            if ops.is_OD
                if ~isfield(ops, 'init_lut_fname') || ~exist([SLM_ops.lut_dir, '\', SLM_ops.init_lut_fname], 'file')   % use linear if not specified
                    error('Overdrive SLM requires regional lut for initialization under "init_lut_fname" param')
                else
                    ops.init_lut_fpath = [SLM_ops.lut_dir, '\', SLM_ops.init_lut_fname];
                end
            else
                ops.lut_path = [SLM_ops.lut_dir '\' SLM_ops.lut_fname];
                if ~exist(ops.lut_path, 'file')
                    error('Lut file "lut_fname" missing from: %s', ops.lut_path);
                end
            end
            
            ops.height = SLM_ops.height;
            ops.width = SLM_ops.width;
            ops.bit_depth = SLM_ops.bit_depth;

        end
        %%
        function obj = init(obj)
            disp("Initializing SLM SDK 4857");

            if ~libisloaded('Blink_C_wrapper')
                loadlibrary([obj.SLM_SDK_dir, '\Blink_C_wrapper.dll'], [obj.SLM_SDK_dir, '\Blink_C_wrapper.h']); % [not_found,warn] = 
            end

            %% - create SDK
            calllib('Blink_C_wrapper', 'Create_SDK', obj.bit_depth, obj.num_boards_found,...
                obj.constructed_okay, obj.is_nematic_type, obj.RAM_write_enable,...
                obj.use_GPU, obj.max_transients, obj.init_lut_fpath);
            
            % Convention follows that of C function return values: 0 is success, nonzero integer is an error
            obj.SDK_created = 0;
            if ~obj.constructed_okay.value   % 0 for v3;  1 for v4.856
                err1 = calllib('Blink_C_wrapper', 'Get_last_error_message');
                if contains(err1, 'simulation')
                    disp(err1)
                    obj.SDK_created = 1;
                end
            else
                obj.SDK_created = 1;
            end
            
            if obj.SDK_created
                obj.board_number = 1;
                disp('Blink SDK was successfully constructed');
                fprintf('Found %u SLM controller(s)\n', obj.num_boards_found.value);
                
                obj.height = calllib('Blink_C_wrapper', 'Get_image_height', obj.board_number);
                obj.width = calllib('Blink_C_wrapper', 'Get_image_width', obj.board_number);
                
                if obj.height == 512
                    % Turn the SLM power on
                    calllib('Blink_C_wrapper', 'SLM_power', 1);
                    calllib('Blink_C_wrapper', 'Set_true_frames', obj.true_frames);
                end
            
                if obj.is_OD
                    % A linear LUT must be loaded to the controller for OverDrive Plus
                    calllib('Blink_C_wrapper', 'Load_linear_LUT', obj.board_number);
                else
                    % load a LUT 
                    calllib('Blink_C_wrapper', 'Load_LUT_file',obj.board_number, obj.lut_path);
                end
            
            else
                disp('Blink SDK was not successfully constructed');
                calllib('Blink_C_wrapper', 'Delete_SDK');
                unloadlibrary('Blink_C_wrapper');
                disp('Deleted SDK')
            end

        end
        %%
        function write_image(ops, image_pointer)

            % loads image 857 ver
            ops.val_complete = calllib('Blink_C_wrapper', 'Write_image', ops.board_number, image_pointer,...
                    ops.width*ops.height, ops.wait_For_Trigger, ops.flip_immediate,...
                    ops.external_Pulse, ops.output_pulse_image_refresh, ops.timeout_ms);    % 
            
        end
        function write_image_OD(ops, image_pointer)
            ops.val_complete = calllib('Blink_C_wrapper', 'Write_overdrive_image', ops.board_number, image_pointer, ...
                    ops.wait_For_Trigger, ops.external_Pulse, ops.timeout_ms);
        end
        function image_write_complete(ops)
            % checks if image is complete
            ops.val_complete = calllib('Blink_C_wrapper', 'ImageWriteComplete', ops.board_number, ops.timeout_ms);
        end
        function load_lut(ops)
            if ops.SDK_created
                fprintf('Uploading lut %s\n', ops.lut_path);
                ops.val_complete = calllib('Blink_C_wrapper', 'Load_LUT_file',ops.board_number, ops.lut_path);
            end
        end
        function load_linear_lut(ops)
            ops.val_complete = calllib('Blink_C_wrapper', 'Load_linear_LUT',ops.board_number);
        end
        
        function close(ops)
            % Always call Delete_SDK before exiting
            if ops.SDK_created
                calllib('Blink_C_wrapper', 'Delete_SDK');
                if ops.height == 512
                    calllib('Blink_C_wrapper', 'SLM_power', 0);
                end
                disp('Deleted SDK')
                ops.SDK_created = 0;
            end
            
            %destruct
            if libisloaded('Blink_C_wrapper')
                unloadlibrary('Blink_C_wrapper');
            end
        end
    end
end


