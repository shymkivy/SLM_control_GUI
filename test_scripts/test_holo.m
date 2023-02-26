x = 0:0.1:50;


y = exp(1i*x);


figure(); hold on
plot(x, real(y))
plot(x, imag(y))


figure;

plot(real(y), imag(y))




exp(1i*1) + exp(1i*2)