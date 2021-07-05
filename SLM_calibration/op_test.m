%% params

m = 512;
n = 512;

stripe_pix_width = 4;

reg_m = 9;
reg_n = 9;


%% make im
stripes_out = f_make_stripes(m, n, stripe_pix_width);

mask_out = f_make_region_mask(m, n, reg_m, reg_n, 32);

mask_out2 = f_make_region_mask(m, n, reg_m, reg_n, 36);


%%
phase1 = stripes_out.*mask_out * pi;

phase2 = (stripes_out * pi).*mask_out2;

phase3 = phase1 + phase2;


figure; imagesc(phase1)
figure; imagesc(phase2)
figure; imagesc(phase3)



im1 = fft2(phase1);
figure; imagesc(abs(fftshift(im1)))

im2 = fft2(phase2);
figure; imagesc(abs(fftshift(im2)))

im3 = fft2(phase3);
figure; imagesc(abs(fftshift(im3)))


