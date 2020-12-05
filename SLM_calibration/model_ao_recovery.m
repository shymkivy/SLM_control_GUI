figure; hold on;
plot([zernike_computed_weights.mode], sqrt([zernike_computed_weights.sm_peak_x_intens_div_fwhm_change]));
plot([zernike_computed_weights.mode], sqrt([zernike_computed_weights.sm_peak_x_intens_change]))





num_freqs = 20;
freqs = 1:num_freqs;
freq_amp = rand(numel(freqs),1)*2 - 1;


x = -10:0.001:10;





sig_dec = zeros(num_freqs, numel(x));
for n_freq = 1:num_freqs
    sig_dec(n_freq,:) = freq_amp(n_freq)*cos(freqs(n_freq)*x);
end
sig = sum(sig_dec);

figure; stem(freqs, freq_amp)
figure; plot(sig);


test_amp = -1:.4:1;
err_all = zeros(n_freq, numel(test_amp));
for n_freq = 1:num_freqs
    for n_test = 1:numel(test_amp)
        err_all(n_freq, n_test) = sum((sig - test_amp(n_test)*cos(freqs(n_freq)*x)).^2);
    end
end

[~, com_amp_idx] = min(err_all,[],2);
comp_amp = test_amp(com_amp_idx);



figure; hold on;
stem(freq_amp)
stem(comp_amp)
legend('real amp', 'computed')




