function [px_all, phi_all_n] = f_lut_fit_gamma(data, order, params)
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

if ~isfield(params, 'plot_stuff')
    params.plot_stuff = 0; 
end
%%
px = data(:,1);
data_fo_r = data(:,2);


%% I ~ cos^2(phi/2); Fl = I^2 (two photon)
data_fo_rn = (data_fo_r).^(1/2);
if params.two_photon
    data_fo_rn = data_fo_rn.^(1/2);
end

data_fo_rn = data_fo_rn - min(data_fo_rn);
data_fo_rn = data_fo_rn/max(data_fo_rn);

data_fo_rns = smoothdata(data_fo_rn, 'gaussian', params.smooth_win);
residual_I = data_fo_rn - data_fo_rns;

if order
    data_fo_rns2 = data_fo_rns;
else
    data_fo_rns2 = max(data_fo_rns) - data_fo_rns;
end


%% first find 2 pi window

[max_val, max_ind] = max(data_fo_rns2);
[min_val2, min_ind2] = min(data_fo_rns2(max_ind:end));
min_ind2 = min_ind2 + max_ind - 1;
[min_val1, min_ind1] = min(data_fo_rns2(1:max_ind));

if order
    txt_offset = [.05 -.05 .05];
else
    txt_offset = [-.05 .05 -.05];
    max_val = max(data_fo_rns) - max_val;
    min_val2 = max(data_fo_rns) - min_val2;
    min_val1 = max(data_fo_rns) - min_val1;
end
%% each piece renormalize and convert to angle
s1 = min_ind1:max_ind;
fo_rns1 = data_fo_rns2(s1) - min(data_fo_rns2(s1));
fo_rns1 = fo_rns1 / max(fo_rns1) * 2 - 1;
phi_s1 = asin(fo_rns1);

s2 = max_ind:min_ind2;
fo_rns2 = data_fo_rns2(s2) - min(data_fo_rns2(s2));
fo_rns2 = fo_rns2 / max(fo_rns2) * 2 - 1;
phi_s2 = asin(fo_rns2);

phi_all = [phi_s1 - pi/2; pi/2 - phi_s2(2:end)];
phi_all_n = phi_all - min(phi_all);
phi_all_n = phi_all_n/max(phi_all_n);

s_all = min_ind1:min_ind2;
px_all = px(s_all);
%% plot 
if params.plot_stuff
    figure; hold on; axis tight;
    plot(px, data_fo_rn);
    plot(px, data_fo_rns);
    plot(px_all, phi_all_n+residual_I(s_all)); % '*' means that this is not real raw, close approximation because no asin transform
    plot(px_all, phi_all_n, 'k', 'LineWidth', 2);
    plot(min_ind1, min_val1, 'ro'); text(min_ind1-5,min_val1+txt_offset(1),'0 pi');
    plot(max_ind, max_val, 'ro'); text(max_ind-5,max_val+txt_offset(2),'1 pi');
    plot(min_ind2, min_val2, 'ro'); text(min_ind2-5,min_val2+txt_offset(3),'2 pi');
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