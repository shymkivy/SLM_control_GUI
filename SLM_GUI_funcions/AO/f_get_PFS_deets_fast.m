function deets = f_get_PFS_deets_fast(im_in, smooth_std, intensity_win)

interp_factor = 5;

im_size = size(im_in,1);

X = 1:im_size;
Xip = linspace(X(1), X(end), numel(X)*interp_factor-interp_factor+1);
[Xq,Yq] = meshgrid(Xip);

%%
im_sm = f_smooth_nd(im_in, smooth_std);
im_sm2 = interp2(double(im_sm),Xq,Yq);
%im_sm2 = f_smooth_nd(im_sm2, smooth_std);

% im_sm = conv2(im_in,conv_kernel, 'same');
% cent_mn_no_interp = f_get_center(im_sm);

% im_sm2 = interp2(double(im_sm),Xq,Yq);
% im_sm2 = conv2(im_sm2,conv_kernel, 'same');

cent_mn_ip = f_get_center(im_sm2);

cent_mn = round([Xip(cent_mn_ip(1)), Xip(cent_mn_ip(2))]);

X_trace_sm = im_sm2(cent_mn_ip(1),:);
Y_trace_sm = im_sm2(:,cent_mn_ip(2));

X_peak = max(X_trace_sm);
X_fwhm = sum(X_trace_sm>(X_peak/2))/interp_factor; 
Y_peak = max(Y_trace_sm);
Y_fwhm = sum(Y_trace_sm>(Y_peak/2))/interp_factor;

if ~exist('intensity_win', 'var')
    intensity_winX = ceil((X_fwhm)/4);
    intensity_winY = ceil((Y_fwhm)/4);
else
    intensity_winX = intensity_win;
    intensity_winY = intensity_win;
end

m_idx = (cent_mn(1)-intensity_winY):(cent_mn(1)+intensity_winY);
m_idx = m_idx(m_idx>0);
m_idx = m_idx(m_idx<=im_size);
n_idx = (cent_mn(2)-intensity_winX):(cent_mn(2)+intensity_winX);
n_idx = n_idx(n_idx>0);
n_idx = n_idx(n_idx<=im_size);
intensity_raw = mean(mean(im_in(m_idx, n_idx)));
intensity_sm = mean(mean(im_sm(m_idx, n_idx)));

deets.intensity_peak = (X_peak + Y_peak)/2;
deets.X_peak = X_peak;
deets.Y_peak = Y_peak;
deets.X_fwhm = X_fwhm;
deets.Y_fwhm = Y_fwhm;
deets.cent_mn = cent_mn;
deets.intensity_mean_raw = intensity_raw;
deets.intensity_mean_sm = intensity_sm;
deets.im_sm = im_sm;
deets.im_sm2 = im_sm2;

end