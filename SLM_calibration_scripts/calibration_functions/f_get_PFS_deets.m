function [deets,params] = f_get_PFS_deets(im_in, params)

% conv kernel smooth vs gauss
if strcmpi(params.smooth_type, 'mean')
    sm_ker_size = 9;
    conv_kernel = ones(sm_ker_size,sm_ker_size)/sm_ker_size^2;
elseif strcmpi(params.smooth_type, 'gauss')
    sigma_pixels = 1;
    kernel_half_size = ceil(sqrt(-log(0.1)*2*sigma_pixels^2));
    [X_gaus,Y_gaus] = meshgrid((-kernel_half_size):kernel_half_size);
    conv_kernel = exp(-(X_gaus.^2 + Y_gaus.^2)/(2*sigma_pixels^2));
    conv_kernel = conv_kernel/sum(conv_kernel(:));
end

filt_win = 5;

im_size = size(im_in,1);

X = 1:im_size;
[Xq,Yq] = meshgrid(linspace(X(1), X(end), numel(X)*params.interp_factor-params.interp_factor+1));

pix_um_raw = X*params.pix_size - params.pix_size;

%%
im_sm = conv2(im_in,conv_kernel, 'same');
cent_mn_no_interp = f_get_center(im_sm);

if params.do_interp
    im_sm2 = interp2(double(im_sm),Xq,Yq);
    im_sm2 = conv2(im_sm2,conv_kernel, 'same');
    pix_um = Xq(1,:)*params.pix_size - params.pix_size;
else
    im_sm2 = im_sm;
    pix_um = pix_um_raw;
end
cent_mn = f_get_center(im_sm2);

if strcmpi(params.fwhm_method, 'smooth_center')
    X_trace = im_in(cent_mn_no_interp(1),:);
    Y_trace = im_in(:,cent_mn_no_interp(2));
    
    X_trace_sm = im_sm2(cent_mn(1),:);
    Y_trace_sm = im_sm2(:,cent_mn(2));
elseif strcmpi(params.fwhm_method, 'marginalize')
    X_trace = mean(im_in,1);
    Y_trace = mean(im_in,2);
    
    X_trace_sm = mean(im_sm2,1);
    Y_trace_sm =  mean(im_sm2,2);
end

X_trace_sm2 = smooth(X_trace, filt_win, 'lowess');
Y_trace_sm2 = smooth(Y_trace, filt_win, 'lowess');

X_peak = max(X_trace_sm);
X_fwhm = sum(X_trace_sm>(X_peak/2))/params.interp_factor; 
Y_peak = max(Y_trace_sm);
Y_fwhm = sum(Y_trace_sm>(Y_peak/2))/params.interp_factor;

if ~isfield(params, 'intensity_win')
    params.intensity_win = round((X_fwhm + Y_fwhm)/4);
end

m_idx = (cent_mn_no_interp(1)-params.intensity_win):(cent_mn_no_interp(1)+params.intensity_win);
m_idx = m_idx(m_idx>0);
m_idx = m_idx(m_idx<=im_size);
n_idx = (cent_mn_no_interp(2)-params.intensity_win):(cent_mn_no_interp(2)+params.intensity_win);
n_idx = n_idx(n_idx>0);
n_idx = n_idx(n_idx<=im_size);
intensity_raw = mean(mean(im_in(m_idx, n_idx)));
intensity_sm = mean(mean(im_sm(m_idx, n_idx)));
                  
deets.X_peak = X_peak;
deets.Y_peak = Y_peak;
deets.X_fwhm = X_fwhm;
deets.Y_fwhm = Y_fwhm;
deets.X_fwhm_um = X_fwhm*params.pix_size;
deets.Y_fwhm_um = Y_fwhm*params.pix_size;
deets.cent_mn = cent_mn;
deets.intensity_raw = intensity_raw;
deets.intensity_sm = intensity_sm;

if params.plot_stuff
    figure;
    subplot(1,2,1); axis tight; hold on;
    plot(pix_um_raw, X_trace);
    plot(pix_um_raw, X_trace_sm2);
    plot(pix_um, X_trace_sm);
    plot(pix_um, X_peak*(X_trace_sm>(X_peak/2)));
    title(sprintf('interp = %d, %s',params.do_interp,params.fwhm_method), 'interpreter', 'none'); xlabel('x axis');
    
    subplot(1,2,2); axis tight; hold on;
    plot(pix_um_raw, Y_trace);
    plot(pix_um_raw, Y_trace_sm2);
    plot(pix_um, Y_trace_sm);
    plot(pix_um, Y_peak*(Y_trace_sm>(Y_peak/2)));
    title(sprintf('interp = %d, %s',params.do_interp,params.fwhm_method), 'interpreter', 'none'); xlabel('y axis');
    legend('raw', 'raw lowess', 'smooth proc');
    
    figure; 
    subplot(1,2,1); axis equal tight; hold on;
    imagesc(pix_um_raw,pix_um_raw,im_in);
    plot(pix_um_raw(cent_mn_no_interp(2)),pix_um_raw(cent_mn_no_interp(1)), 'ro');
    rectangle('Position',[pix_um_raw(cent_mn_no_interp(2)-params.intensity_win) pix_um_raw(cent_mn_no_interp(1)-params.intensity_win) 2*params.intensity_win*params.pix_size 2*params.intensity_win*params.pix_size])
    
    subplot(1,2,2); axis equal tight; hold on;
    imagesc(pix_um,pix_um,im_sm2);
    plot(pix_um(cent_mn(2)),pix_um(cent_mn(1)), 'ro');
    title(sprintf('interp = %d, %s',params.do_interp,params.fwhm_method), 'interpreter', 'none'); xlabel('x axis');
end

end