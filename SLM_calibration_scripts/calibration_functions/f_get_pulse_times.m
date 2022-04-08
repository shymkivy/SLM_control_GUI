function [onset, offset] = f_get_pulse_times(trace,thresh, quant_limit)

if ~exist('thresh', 'var') || isempty(thresh)
    thresh = 0.5; % default 0.5
end
if ~exist('quant_limit', 'var') || isempty(quant_limit)
    quant_limit = 15; % default 15
end

norm_trace = if_rescale(trace);

% first identify the pulses
norm_trace(norm_trace<thresh) = 0;
norm_trace(norm_trace>thresh) = 1;

onset = find(diff(norm_trace)>0)+1;
offset = find(diff(norm_trace)<0);

% quality check if light turns off in beginning 
if and(norm_trace(1) == 1,numel(offset)>numel(onset))
    offset(1) = [];
end

if numel(onset) > quant_limit
    figure; plot(norm_trace);
    title(['Stopped because number of pulses is over limit of ' num2str(quant_limit)]);
    error(['Stopped because number of pulses is over limit of ' num2str(quant_limit)]);
end

end

function norm_trace = if_rescale(trace)

base = min(trace);
base_sub = trace - base;
peak = max(base_sub);
norm_trace = base_sub/peak;

end
