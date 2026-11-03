function [yf, w_fit] = f_sg_fit_simple(x, y, fit_type)
% poly1 / poly2 / spline / linearinterp fit. Uses the Curve Fitting Toolbox
% when present (cfit), otherwise base MATLAB (function handle, column output like cfit).
% w_fit = polynomial coefficients, highest power first (0 for interpolants).

x = x(:);
y = y(:);

if f_sg_has_curvefit()
    yf = fit(x, y, fit_type);
    if strcmpi(fit_type, 'poly1')
        w_fit = [yf.p1 yf.p2];
    elseif strcmpi(fit_type, 'poly2')
        w_fit = [yf.p1 yf.p2 yf.p3];
    else
        w_fit = 0;
    end
    return;
end

if strcmpi(fit_type, 'poly1')
    w_fit = polyfit(x, y, 1);
    yf = @(z) reshape(polyval(w_fit, z), [], 1);
elseif strcmpi(fit_type, 'poly2')
    w_fit = polyfit(x, y, 2);
    yf = @(z) reshape(polyval(w_fit, z), [], 1);
elseif strcmpi(fit_type, 'spline')
    pp = spline(x, y);                          % not-a-knot, same as cfit 'spline'
    yf = @(z) reshape(ppval(pp, z), [], 1);
    w_fit = 0;
elseif strcmpi(fit_type, 'linearinterp')
    F = griddedInterpolant(x, y, 'linear', 'linear');   % linear extrapolation outside data
    yf = @(z) reshape(F(z), [], 1);
    w_fit = 0;
else
    error('f_sg_fit_simple: fit type "%s" needs the Curve Fitting Toolbox', fit_type);
end
end
