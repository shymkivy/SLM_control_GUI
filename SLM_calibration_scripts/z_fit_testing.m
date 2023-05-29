
% fianium at NAeff 0.565 (i think)
% SLM_loc = [-250, -200, -150, -100, -50, 0, 50, 100, 150, 200, 250];
% 
% no_corr_loc = [239, 190, 143, 95, 49, 0, -48, -97, -146, -192, -241];
% corr_loc = [256, 200, 148, 98, 48, 0, -48, -95, -141, -184, -228];

% maitai at NAeff 0.5
SLM_loc = [-250, -200, -150, -100, -50, 0, 50, 100, 150, 200, 250];

no_corr_loc = [151, 120, 91.8, 62, 31.9, 0, -30, -59, -89, -118.8, -148.8];
corr_loc = [161, 128, 94.5, 62, 31, 0, -29.5, -58, -86.4, -113.7, -140];



z_loc2 = min(SLM_loc):max(SLM_loc);

yf = fit(SLM_loc', no_corr_loc', 'poly1');
yf_corr = fit(SLM_loc', corr_loc', 'poly1');

figure; hold on
plot(SLM_loc, -no_corr_loc, 'o')
plot(z_loc2, -yf(z_loc2))
plot(SLM_loc, -corr_loc, 'o')
plot(z_loc2, -yf_corr(z_loc2))
legend('no corr', 'no corr fit', 'corr', 'corr fit')

figure; plot(no_corr_loc' - yf(SLM_loc))

MSE = mean((no_corr_loc' - yf(SLM_loc)).^2);

MSE_corr = mean((corr_loc' - yf(SLM_loc)).^2);

MSE2 = mean((no_corr_loc' - yfna(SLM_loc)).^2);

% sqrt(1 - x) ~ 1 - x/2 - x^2/8 - x^3/16 - 5x^4/128

f1 = @(s1, x)  -x*sqrt(1 - (s1).^2);

f1 = @(s1, x)  -x*(1 - (s1.^2)/2 - (s1.^4)/8 - (s1.^6)/16);

f1 = @(s1, x)  x*(- (s1.^2)/2 - (s1.^4)/8 - (s1.^6)/16);


yf

no_corr_loc/0.9593

%f1 = @(s1, x)  x*sqrt(1 - sin(s1).^2);
fitfun = fittype(f1);
yfna = fit(SLM_loc', no_corr_loc', fitfun, 'Lower', 0.1, 'Upper', 1); % , , 'StartPoint', rand(1)

NAeff = 0.5


phase = objectiveRI * k * sqrt(1 - RHO.^2 * sin_alpha^2);

cos_alpha = cos(asin(sin_alpha));
bias = (2*objectiveRI*k)/(3*sin_alpha^2)*(1 - cos_alpha^3);

defocus = -(phase - bias);


alpha = 0.91

NA = 0.1:0.01:1;



zc = -sqrt(1 - sin(asin(NA/1.33)).^2) - 2./(3*sin(asin(NA/1.33)).^2).*(1-cos(asin(NA/1.33)).^3);

figure;
plot(NA, zc)

NA = 0.565;

f1 = @(s1,x) x*(-sqrt(1 - sin(asin(NA/s1/1.33)).^2) - 2./(3*sin(asin(NA/s1/1.33)).^2).*(1-cos(asin(NA/s1/1.33)).^3));
fitfun = fittype(f1);
yf = fit(SLM_loc', no_corr_loc', fitfun, 'Lower', 0.2, 'Upper', 2); % , , 'StartPoint', rand(1)



yf(250)









