

ang1 = -pi:0.01:pi;
num_ang = numel(ang1);
ones1 = ones(1,num_ang);

ang_out = angle(exp(1i*ang1));
ang_out1 = angle(exp(1i*ang1) + 0.5);
ang_out2 = angle(exp(1i*ang1) + 1);
ang_out3 = angle(exp(1i*ang1) + 2);

vals = [0,1,2];
fac = 3;


figure; hold on
for n1 = 1:numel(vals)
    exp_comb = exp(1i*ang1) + fac*exp(1i*ones1.*vals(n1));
    ang_out = angle(exp_comb);
    plot(ang_out-n1)
end
title('phase before and after')

figure; hold on
for n1 = 1:numel(vals)
    exp_comb = exp(1i*ang1) + fac*exp(1i*ones1.*vals(n1));
    mag_out = abs(exp_comb);
    plot(mag_out)
end
title('phase before and after')

figure; hold on
for n1 = 1:numel(vals)
    exp_comb = exp(1i*ang1) + fac*exp(1i*ones1.*vals(n1));
    plot(real(exp_comb), imag(exp_comb))
end
title('phase before and after')


figure;
plot(abs(exp(1i*ang1)))
title('magnitude')

figure; hold on;
plot(real(exp(1i*ang1)))
plot(imag(exp(1i*ang1)))
legend('real', 'imaginary')
title('real-imag components')

figure; plot(real(exp(1i*ang1)), imag(exp(1i*ang1)))



