function [Z_nm, n, m] = f_SLM_zernike_pol(rho, theta, n, m)

[SLMm, SLMn] = size(rho);
% m = -1;
% n = 3;

if n < 0
   n = abs(n);
   warnign('For zernike polynomials n must be n>=0; n was made positive');
end

if abs(m) > n
   m = m/abs(m)*n;
   warning('For zernike polynomials m must be abs(m) >= n; m was modified');
end

m_p = abs(m);

k_max = (n-m_p)/2;


R = zeros(SLMm, SLMn,k_max+1);

for k = 0:k_max
    R(:,:,k+1) = ((-1)^k*factorial(n-k))/(factorial(k)*factorial((n+m_p)/2-k)*factorial((n-m_p)/2 - k))*rho.^(n-2*k);
end

R_nm = sum(R,3);

if m > 0
    Z_nm = R_nm .* cos(m_p*theta);
elseif m < 0
    Z_nm = R_nm .* sin(m_p*theta);
else
    Z_nm = R_nm;
end
end