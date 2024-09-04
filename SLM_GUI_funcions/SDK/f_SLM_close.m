function ops = f_SLM_close(ops)
% reg and OD
ops.sdkObj.close();

% if strcmpi(ops.SLM_type, 'BNS1920')
%     ops = f_SLM_sdk4857_close(ops);
% elseif strcmpi(ops.SLM_type, 'BNS512OD') || strcmpi(ops.SLM_type, 'BNS512')
%     if ops.sdk3_ver
%         ops = f_SLM_BNS512OD_sdk3_close(ops);
%     else
%         ops = f_SLM_BNS512OD_close(ops);
%     end
% else
%     error('Undefined SLM in f_SLM_close');
% end

end