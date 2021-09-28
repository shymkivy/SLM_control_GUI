%% params

m = 512;
n = 512;

stripe_pix_width = 4;

reg_m = 9;
reg_n = 9;


%% make im
stripes_out = f_make_stripes(m, n, stripe_pix_width);

mask_out = f_make_region_mask(m, n, reg_m, reg_n, 32);

mask_out2 = f_make_region_mask(m, n, reg_m, reg_n, 33);


%%
phase1 = stripes_out.*mask_out * pi;
plot_stuff =0;

fo_mags = zeros(20,1);
for n_base = 1:20
    phase2 = (stripes_out * pi+n_base*pi/10).*mask_out2;
    phase3 = phase1 + phase2;
    %phases_out = angle(exp(1i*(phase3)));
    phases_out = phase3;
    im1 = fft2(phases_out);
    im2 = abs(fftshift(im1));
    im3 = im2(251:263,313:329);
    fo_mags(n_base) = sum(im3(:));
    if plot_stuff
        figure; 
        subplot(1,3,1); 
        imagesc(phases_out); caxis([-pi pi]);
        title(num2str(n_base))
        subplot(1,3,2);
        imagesc(im2);
        subplot(1,3,3);
        imagesc(im3);
    end
end

figure; plot(fo_mags)

figure; imagesc(phase2)

im1 = fft2(phases_out);
figure; imagesc(abs(fftshift(im1)))

im2 = fft2(phase2);
figure; imagesc(abs(fftshift(im2)))

im3 = fft2(phase3);
figure; imagesc(abs(fftshift(im3)))


