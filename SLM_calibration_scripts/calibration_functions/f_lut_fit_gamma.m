function [px_all, phi_all_n] = f_lut_fit_gamma(data, order, params, min_max_min_ind)
% data [pixels, intensity]

%%
if ~exist('params', 'var')
    params = struct;
end

if ~exist('order', 'var')
    order = 1; % default is first order, zero order flips graph
end

if ~isfield(params, 'smooth_win')
    params.smooth_win = 15;
end

if ~isfield(params, 'two_photon')
    params.two_photon = 1; % assumes Fl ~ I^2 and takes sqrt
end

if ~isfield(params, 'manual_peak_selection')
    params.manual_peak_selection = 0; 
end

if ~isfield(params, 'plot_stuff')
    params.plot_stuff = 0; 
end
%%
px = data(:,1);
data_fo_r = data(:,2);

%% I ~ cos^2(phi/2); Fl = I^2 (two photon)
data_fo_r2 = (data_fo_r).^(1/2);
if params.two_photon
    data_fo_r2 = data_fo_r2.^(1/2);
end

if params.smooth_win
    data_fo_rs = smoothdata(data_fo_r2, 'gaussian', params.smooth_win);
else
    data_fo_rs = data_fo_r2;
end

data_min = min(data_fo_rs);
data_max = max(data_fo_rs - min(data_fo_rs));

data_fo_rsn = (data_fo_rs - data_min)./data_max;
data_fo_rn = (data_fo_r2 - data_min)./data_max;

residual_I = data_fo_rn - data_fo_rsn;

if order
    data_fo_rsn2 = data_fo_rsn;
else
    data_fo_rsn2 = max(data_fo_rsn) - data_fo_rsn;
end
% 
% data_fo_rsns = smoothdata(data_fo_rsn, 'gaussian', 20);
% 
% figure; hold on
% plot(px, data_fo_rn);
% plot(px, data_fo_rsn);
% plot(px, data_fo_rsns);
% 
% 
% figure;
% plot(diff(data_fo_rsn));
% 
% figure;
% plot(diff(diff(data_fo_rsn)));
% 


%% first find 2 pi window
if ~exist('min_max_min_ind', 'var')
    min_max_min_ind = f_lut_peak_selection(lut_trace, params.manual_peak_selection, order, params.plot_stuff);
end

min_max_min_ind2 = min_max_min_ind;

peak_buff = 10;

x = min_max_min_ind(1);
[min_val1, min_ind1] = min(data_fo_rsn2((x-peak_buff):(x+peak_buff)));
min_max_min_ind2(1) = min_ind1 + x - peak_buff - 1;

x = min_max_min_ind(2);
[max_val, max_ind] = max(data_fo_rsn2((x-peak_buff):(x+peak_buff)));
min_max_min_ind2(2) = max_ind + x - peak_buff - 1;

x = min_max_min_ind(3);
[min_val2, min_ind2] = min(data_fo_rsn2((x-peak_buff):(x+peak_buff)));
min_max_min_ind2(3) = min_ind2 + x - peak_buff - 1;

%%
if order
    txt_offset = [.05 -.05 .05];
else
    txt_offset = [-.05 .05 -.05];
    max_val = max(data_fo_rns) - max_val;
    min_val2 = max(data_fo_rns) - min_val2;
    min_val1 = max(data_fo_rns) - min_val1;
end
%% each piece renormalize and convert to angle
% data_fo_rn_cut = data_fo_rn(min_max_min_ind2(1):min_max_min_ind2(3));
% data_fo_rn_cut_s = smoothdata(data_fo_rn_cut, 'gaussian', params.smooth_win);
% px_cut = px(min_max_min_ind2(1):min_max_min_ind2(3));
% 
% figure; hold on
% plot(px, data_fo_rn);
% plot(px, data_fo_rns);
% plot(px_cut, data_fo_rn_cut_s);

s1 = min_max_min_ind2(1):min_max_min_ind2(2);
fo_rns1 = data_fo_rsn2(s1) - min(data_fo_rsn2(s1));
fo_rns1 = fo_rns1 / max(fo_rns1) * 2 - 1;
phi_s1 = asin(fo_rns1);

s2 = min_max_min_ind2(2):min_max_min_ind2(3);
fo_rns2 = data_fo_rsn2(s2) - min(data_fo_rsn2(s2));
fo_rns2 = fo_rns2 / max(fo_rns2) * 2 - 1;
phi_s2 = asin(fo_rns2);

phi_all = [phi_s1 - pi/2; pi/2 - phi_s2(2:end)];
phi_all_n = phi_all - min(phi_all);
phi_all_n = phi_all_n/max(phi_all_n);

s_all = min_max_min_ind2(1):min_max_min_ind2(3);
px_all = px(s_all);
%% plot 
if params.plot_stuff
    figure; hold on; axis tight;
    plot(px, data_fo_rn);
    plot(px, data_fo_rsn);
    plot(px_all, phi_all_n+residual_I(s_all)); % '*' means that this is not real raw, close approximation because no asin transform
    plot(px_all, phi_all_n, 'k', 'LineWidth', 2);
    plot(px(min_max_min_ind2(1)), min_val1, 'ro'); text(px(min_max_min_ind2(1))-2,min_val1+txt_offset(1),'0 pi');
    plot(px(min_max_min_ind2(2)), max_val, 'ro'); text(px(min_max_min_ind2(2))-2,max_val+txt_offset(2),'1 pi');
    plot(px(min_max_min_ind2(3)), min_val2, 'ro'); text(px(min_max_min_ind2(3))-2,min_val2+txt_offset(3),'2 pi');
    xlabel('pixel val SLM');
    ylabel('image intensity');
    legend('P raw (power)', 'P smooth', 'phi raw*', 'phi smooth', 'Location', 'northwest');
    if order
        title(sprintf('First order gamma cal; smooth=%d; 2pcorr=%d',params.smooth_win,params.two_photon));
    else
        title(sprintf('Zero order gamma cal; smooth=%d; 2pcorr=%d',params.smooth_win,params.two_photon));
    end
end

end