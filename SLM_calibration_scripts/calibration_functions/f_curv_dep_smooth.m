function trace_out = f_curv_dep_smooth(trace, curv_range)
% smooth more at low curvature and less at high curvature

max_sm = max(curv_range);
min_sm = min(curv_range);

ones1 = ones(size(trace));

filt_std = min_sm;
gaus_kernel = if_get_gauss_kern(filt_std);

trace_s = conv(trace, gaus_kernel, 'same')./conv(ones1, gaus_kernel, 'same');
%trace_s = smoothdata(trace, 'gaussian', max_sm);

s_min = min(trace_s);
s_max = max(trace_s - s_min);

trace_n = (trace - s_min)./s_max;
trace_sn = (trace_s - s_min)./s_max;

trace_sdd = [0 diff(diff(trace_s)) 0];
trace_sddrn = abs(trace_sdd)./max(abs(trace_sdd));

figure; hold on;
plot(trace_n);
plot(trace_sn);
plot(trace_sddrn);
title(sprintf('Filt sm=%.1f', filt_std));

% variable filt
s_win = (1-trace_sddrn) * (max_sm - min_sm) + min_sm;


% [1 : mid-1] [mid : end]
for n_pt = 1:numel(trace)
    temp_kernel = if_get_gauss_kern(s_win(n_pt));
    mid1 = round(numel(temp_kernel+1)/2);
    numel(temp_kernel)
    
    
    n_pt
    
    left_siz = n_pt-1;
    right_siz = 
    
    
    
    trace1 = conv(ones1, temp_kernel);
    
end



trace_s1 = conv(trace, gaus_kernel, 'same');

ones_s = conv(ones(numel(trace),1), gaus_kernel, 'same');

figure; plot(ones_s)

figure; hold on;
plot(trace_s)
plot(trace_s1./ones_s')

figure; plot(gaus_kernel)

figure; plot(s_win)

end

function gaus_kernel = if_get_gauss_kern(g_std)

kernel_half_size = ceil(sqrt(-log(0.05)*2*g_std^2));
gaus_win = -kernel_half_size:kernel_half_size;
gaus_kernel = exp(-((gaus_win).^2)/(2*g_std^2));
gaus_kernel = gaus_kernel/sum(gaus_kernel);

end


