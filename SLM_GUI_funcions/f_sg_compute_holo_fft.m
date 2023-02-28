function [im_amp, x_lab, y_lab] = f_sg_compute_holo_fft(reg1, holo_image, defocus_dist)

dims = size(holo_image);
%siz = max(dims);

%phase_sq = zeros(dims);

% beam shape
Lx = linspace(-dims(2)/reg1.phase_diameter, dims(2)/reg1.phase_diameter, dims(2));
Ly = linspace(-dims(1)/reg1.phase_diameter, dims(1)/reg1.phase_diameter, dims(1));
sigma = 1;

%Lx = linspace(-(siz-1)/2,(siz-1)/2,siz);
%sigma = reg1.beam_diameter/2; 			% beam waist/2

[c_X, c_Y] = meshgrid(Lx, Ly);
x0 = 0;                 % beam center location
y0 = 0;                 % beam center location
A = 1;                  % peak of the beam 
res = ((c_X-x0).^2 + (c_Y-y0).^2)./(2*sigma^2);
pupil_amp = A  * exp(-res);

%pupil_mask = false(siz,siz);
%pupil_mask((1 + (siz - dims(1))/2):(siz - (siz - dims(1))/2),(1 + (siz - dims(2))/2):(siz - (siz - dims(2))/2)) = 1;

%pupil_amp(~pupil_mask) = 0;

defocus = f_sg_DefocusPhase(reg1);

%defocus2 = phase_sq;
%defocus2(pupil_mask) = defocus;

%holo_image1 = phase_sq;
%holo_image1(pupil_mask) = holo_image;

SLM_complex_wave=pupil_amp.*(exp(1i.*holo_image)./exp(1i.*(defocus_dist.*defocus*1e-6)));

im1 = fftshift(fft2(SLM_complex_wave));
im_amp = abs(im1)/prod(dims);

% figure()
% imagesc(im_amp)

x_lab = linspace(-(dims(2)-1)/2, (dims(2)-1)/2, reg1.phase_diameter)/2;
y_lab = linspace(-(dims(1)-1)/2, (dims(1)-1)/2, reg1.phase_diameter)/2;

% if app.fftampsquaredCheckBox.Value
%im_amp = im_amp.^2;
% end
% 
% xy_axis = linspace(-(siz-1)/2, (siz-1)/2, siz)/2;
% 
% 
% Fs = 1000;            % Sampling frequency                    
% T = 1/Fs;             % Sampling period       
% L = 1500;             % Length of signal
% t = (0:L-1)*T;        % Time vector
% 
% S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
% 
% X = S + 2*randn(size(t));
% 
% figure()
% plot(1000*t(1:50),S(1:50))
% title('Signal Corrupted with Zero-Mean Random Noise')
% xlabel('t (milliseconds)')
% ylabel('X(t)')
% 
% Y = fft(S);
% 
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = (2*P1(2:end-1)).^2;
% 
% f = Fs*(0:(L/2))/L;
% figure()
% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
% 
% X2 = ifft(Y);
% 
% n = 2^nextpow2(dims(2))
% 
% 
% fs = 100;               % sampling frequency
% t = 0:(1/fs):(10-1/fs); % time vector
% S = cos(2*pi*15*t);
% n = length(S);
% X = fft(S);
% f = (0:n-1)*(fs/n);     %frequency range
% power = (2*abs(X)/n).^2;    %power
% plot(f,power)

end