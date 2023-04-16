function deets = f_get_PFS_deets_fast(im_in, smooth_std, intensity_win)

interp_factor = 5;

im_size = size(im_in,1);

X = 1:im_size;
[Xq,Yq] = meshgrid(linspace(X(1), X(end), numel(X)*interp_factor-interp_factor+1));

%%
im_sm = f_smooth_nd(im_in, smooth_std);
cent_mn_no_interp = f_get_center(im_sm);

im_sm2 = interp2(double(im_sm),Xq,Yq);
im_sm2 = f_smooth_nd(im_sm2, smooth_std);

% im_sm = conv2(im_in,conv_kernel, 'same');
% cent_mn_no_interp = f_get_center(im_sm);

% im_sm2 = interp2(double(im_sm),Xq,Yq);
% im_sm2 = conv2(im_sm2,conv_kernel, 'same');

cent_mn = f_get_center(im_sm2);

X_trace_sm = im_sm2(cent_mn(1),:);
Y_trace_sm = im_sm2(:,cent_mn(2));

X_peak = max(X_trace_sm);
X_fwhm = sum(X_trace_sm>(X_peak/2))/interp_factor; 
Y_peak = max(Y_trace_sm);
Y_fwhm = sum(Y_trace_sm>(Y_peak/2))/interp_factor;

if ~exist('intensity_win', 'var')
    intensity_win = ceil((X_fwhm+Y_fwhm)/4);
end

m_idx = (cent_mn_no_interp(1)-intensity_win):(cent_mn_no_interp(1)+intensity_win);
m_idx = m_idx(m_idx>0);
m_idx = m_idx(m_idx<=im_size);
n_idx = (cent_mn_no_interp(2)-intensity_win):(cent_mn_no_interp(2)+intensity_win);
n_idx = n_idx(n_idx>0);
n_idx = n_idx(n_idx<=im_size);
intensity_raw = mean(mean(im_in(m_idx, n_idx)));
intensity_sm = mean(mean(im_sm(m_idx, n_idx)));
                  
deets.X_peak = X_peak;
deets.Y_peak = Y_peak;
deets.X_fwhm = X_fwhm;
deets.Y_fwhm = Y_fwhm;
deets.cent_mn = [Yq(cent_mn(1),1); Xq(1,cent_mn(2))];
deets.intensity_raw = intensity_raw;
deets.intensity_sm = intensity_sm;
deets.im_sm = im_sm;
deets.im_sm2 = im_sm2;

end