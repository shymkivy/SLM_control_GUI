function f_trace = f_lut_get_mean_intensity(im_stack, yx_pts, z_thresh, plot_stuff, method)
if ~exist('plot_stuff', 'var')
    plot_stuff = 0;
end

if ~exist('z_thresh', 'var')
    z_thresh = 1;
end

if ~exist('method', 'var')
    method = 'max_fwhm'; % gauss_fit max_fwhm conv_max
end

ds = 75;
mean_fr = mean(im_stack,3);

y0 = round((yx_pts(1)-ds):(yx_pts(1)+ds));
x0 = round((yx_pts(2)-ds):(yx_pts(2)+ds));

y0marg = mean(mean_fr(y0,x0),1);
x0marg = mean(mean_fr(y0,x0),2);

base = double(mean(mean(mean_fr(y0, x0))));

ker_size = 8;
kernel1 = ones(ker_size,ker_size)/ker_size^2;
mean_fr_sm = conv2(mean_fr(y0, x0),kernel1, 'same');

if strcmpi(method, 'gauss_fit')
    try
        yf = fit(y0' ,y0marg'-base,'gauss1');
        xf = fit(x0' ,x0marg-base,'gauss1');
    catch
        warning('make sure you have curve fitting toolbox');
    end
    
    x0_fit = xf.a1*exp(-((x0-xf.b1)./xf.c1).^2)+base;
    y0_fit = yf.a1*exp(-((y0-yf.b1)./yf.c1).^2)+base;
    
    x0mu = xf.b1;
    y0mu = yf.b1;
    
    x0width = xf.c1*z_thresh;
    y0width = yf.c1*z_thresh;
elseif strcmpi(method, 'max_fwhm')
    x0_fit = smoothdata(x0marg,'movmean',ker_size);
    y0_fit = smoothdata(y0marg,'movmean',ker_size);
    
    [x0max, x0argmax_ind] = max(x0_fit);
    x0mu = x0(x0argmax_ind);
    
    [y0max, y0argmax_ind] = max(y0_fit);
    y0mu = y0(y0argmax_ind);
    
    x0width = sum(x0marg>(x0max-(x0max-base)/2))/2*z_thresh;
    y0width = sum(y0marg>(y0max-(y0max-base)/2))/2*z_thresh;
elseif strcmpi(method, 'conv_max')
    x0_fit = smoothdata(x0marg,'movmean',ker_size);
    y0_fit = smoothdata(y0marg,'movmean',ker_size);
    
    [max1, max_ind] = max(mean_fr_sm(:));
    [y0mu_ind, x0mu_ind] = ind2sub(size(mean_fr_sm), max_ind);
    
    y0mu = y0(y0mu_ind);
    x0mu = x0(x0mu_ind);
    
    x0width = sum(mean_fr_sm(y0mu_ind,:)>(max1-(max1-base)/2))*z_thresh;
    y0width = sum(mean_fr_sm(:,x0mu_ind)>(max1-(max1-base)/2))*z_thresh;
end

x0_new = round((x0mu - x0width):(x0mu + x0width));
y0_new = round((y0mu - y0width):(y0mu + y0width));

im_substack2 = im_stack(y0_new, x0_new,:);

f_trace = squeeze(mean(mean(im_substack2,1),2));

if plot_stuff
%     figure; hold on;
%     plot(y0, y0marg);
%     plot(y0, y0_fit);
%     title('y marginalized intensity')
% 
%     figure; hold on;
%     plot(x0, x0marg);
%     plot(x0, x0_fit);
%     title('x marginalized intensity')
    
    figure; hold on; axis tight equal;
    imagesc(x0,y0, mean_fr_sm);
    plot(x0mu, y0mu, 'or');
    title('original smoothed');
    
    figure; hold on; axis tight equal;
    imagesc(x0_new,y0_new, mean_fr(y0_new, x0_new));
    plot(x0mu, y0mu, 'or');
    title(sprintf('centered point, %s, %.1fz', method, z_thresh), 'interpreter', 'none');
    
    figure;
    plot_int = floor(size(im_substack2,3)/9);
    for n_plot = 1:9
        interval = (plot_int*(n_plot-1)+1):(plot_int*n_plot);
        subplot(3,3,n_plot); hold on; axis tight equal;
        imagesc(x0_new,y0_new, mean(im_substack2(:,:,interval),3));axis image;
        plot(x0mu, y0mu, 'or');
        title(sprintf('Gray pix %d-%d', interval(1), interval(end)));
    end
    
    figure;
    plot(f_trace);
    title('intensity vs phase');
end




end