function ops = f_SLM_initialize(ops)

%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%%
if strcmpi(ops.SLM_params_use.SDK_ver, '4851')
    ops.sdkObj = sdk4851(ops.SLM_params_use);
elseif strcmpi(ops.SLM_params_use.SDK_ver, '4857')
    ops.sdkObj = sdk4857(ops.SLM_params_use);
else
    error("SLM object for sdk_ver '%s' doesn't exist", ops.SDK_ver);
end

ops.sdkObj.init();

%% set default SLM if not specified
% if ~isfield(ops, 'SLM_type')
%     warning('Undefined SLM, using BNS1920 as default')
%     ops.SLM_type = 'BNS1920'; % BNS1920 is standard
% end

%%
% if ~isfield(ops, 'lut_dir')
%     ops.lut_dir = 'lut_calibration\';
% end

%% Lut global
% if ~isfield(ops, 'lut_fname')
%     ops.lut_fname = 'linear.lut';
% end
% 
% lut_path = [ops.lut_dir '\' ops.lut_fname];
% 
% if ~exist(lut_path, 'file')
%     error('lut file missing: %s',lut_path);
% end

%%
% ops.SDK_created = 0;
% 
% if ~ops.sdk3_ver
%     if strcmpi(ops.SLM_type, 'BNS1920')
%         ops = f_SLM_sdk4857_init(ops);
%         %ops = f_SLM_BNS1920_sdk4_initialize(ops);
%     elseif strcmpi(ops.SLM_type, 'BNS512OD')
%         ops = f_SLM_sdk4857_init(ops);
%         %ops = f_SLM_BNS512OD_sdk4_initialize(ops);
%     elseif strcmpi(ops.SLM_type, 'BNS512')
%         ops = f_SLM_sdk4857_init(ops);
%         %ops = f_SLM_BNS512_sdk4_initialize(ops);
%     else
%         error('Undefined SLM in f_SLM_initialize');
%     end
% else
%     ops.SLM_SDK_dir = ops.SLM_SDK3_dir;
%     if strcmpi(ops.SLM_type, 'BNS1920')
%         ops = f_SLM_BNS1920_sdk3_initialize(ops);
%     elseif strcmpi(ops.SLM_type, 'BNS512OD')
%         ops = f_SLM_BNS512OD_sdk3_initialize(ops);
%     elseif strcmpi(ops.SLM_type, 'BNS512')
%         ops = f_SLM_BNS512_sdk3_initialize(ops);
%     else
%         error('Undefined SLM in f_SLM_initialize');
%     end
% end
% 
% % needed for ver 4, because needs to unload library for some reason
% if ~ops.SDK_created
%     ops = f_SLM_close(ops);
% end

%SLM1 = sdk4857
%SLM1.init(1)

%% load imagegen library which is in new BNS 1920 slm sdk path

%f_SLM_BNS_load_imagegen(ops);

end