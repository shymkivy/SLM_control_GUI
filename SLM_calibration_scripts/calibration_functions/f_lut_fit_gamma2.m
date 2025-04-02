function [px_all, phi_all_n, mmm_ind] = f_lut_fit_gamma2(data, params)
% data [pixels, intensity]
% with no smooth

%%
if ~exist('params', 'var')
    params = struct;
end

if isfield(params, 'order')
    order = params.order; % default is first order, zero order flips graph
else
    order = 1;
end

if isfield(params, 'plot_stuff')
    plot_stuff = params.plot_stuff; 
else
    plot_stuff = 0;
end

if isfield(params, 'min_max_min_ind')
    mmm_ind = params.min_max_min_ind;
else
    mmm_ind = [];
end
%%
num_pix = numel(data);
px = (1:num_pix)-1;

if order
    data_fo_r = data;
else
    data_fo_r = max(data) - data;
end

%% normalize

data_fo_rn = data_fo_r - min(data_fo_r);
data_fo_rn = data_fo_rn/max(data_fo_rn);

%% first find 2 pi window
if isempty(mmm_ind) % min max min index
    mmm_ind = f_lut_peak_selection(data_fo_rn, params);
end
mmm_val = zeros(3,1);

peak_buff = 10;

x = mmm_ind(1);
min_max_win = max(x-peak_buff,1):min(x+peak_buff,num_pix);
[mmm_val(1), min_ind1] = min(data_fo_rn(min_max_win));
mmm_ind(1) = min_max_win(min_ind1);

x = mmm_ind(2);
min_max_win = max(x-peak_buff,1):min(x+peak_buff,num_pix);
[mmm_val(2), max_ind] = max(data_fo_rn(min_max_win));
mmm_ind(2) = min_max_win(max_ind);

x = mmm_ind(3);
min_max_win = max(x-peak_buff,1):min(x+peak_buff,num_pix);
[mmm_val(3), min_ind2] = min(data_fo_rn(min_max_win));
mmm_ind(3) = min_max_win(min_ind2);

%%
if order
    txt_offset = [.05 -.05 .05];
else
    txt_offset = [-.05 .05 -.05];
    mmm_val(1) = max(data_fo_rn) - mmm_val(1);
    mmm_val(2) = max(data_fo_rn) - mmm_val(2);
    mmm_val(3) = max(data_fo_rn) - mmm_val(3);
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

% I ~ cos^2(phi/2) = (cos(phi)+1)/2; Fl = I^2 (two photon)

s1 = mmm_ind(1):mmm_ind(2);
fo_rn = data_fo_rn(s1) - min(data_fo_rn(s1));
fo_rn = fo_rn / max(fo_rn) * 2 - 1;
phi_s1 = asin(fo_rn);

s2 = mmm_ind(2):mmm_ind(3);
fo_rn = data_fo_rn(s2) - min(data_fo_rn(s2));
fo_rn = fo_rn / max(fo_rn) * 2 - 1;
phi_s2 = asin(fo_rn);

phi_all = [phi_s1 - pi/2; pi/2 - phi_s2(2:end)];
phi_all_n = phi_all - min(phi_all);
phi_all_n = phi_all_n/max(phi_all_n);

s_all = mmm_ind(1):mmm_ind(3);
px_all = px(s_all);
%% plot 
if plot_stuff
    figure; hold on; axis tight;
    plot(px, data_fo_rn);
    plot(px_all, phi_all_n, 'k', 'LineWidth', 2);
    plot(px(mmm_ind(1)), mmm_val(1), 'ro'); text(px(mmm_ind(1))-2,mmm_val(1)+txt_offset(1),'0 pi');
    plot(px(mmm_ind(2)), mmm_val(2), 'ro'); text(px(mmm_ind(2))-2,mmm_val(2)+txt_offset(2),'1 pi');
    plot(px(mmm_ind(3)), mmm_val(3), 'ro'); text(px(mmm_ind(3))-2,mmm_val(3)+txt_offset(3),'2 pi');
    xlabel('pixel val SLM');
    ylabel('image intensity');
    legend('Average E', 'phase', 'Location', 'northwest');
    if order
        title(sprintf('First order gamma cal'));
    else
        title(sprintf('Zero order gamma cal'));
    end
end

end