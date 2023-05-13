function [yf, w_fit, fit_eq] = f_sg_do_fit(x, y, params)

if strcmpi(params.fit_type, 'poly1_constrain_z0')
    w_fit = x\y;
    yf = @(n) w_fit*n;
    fit_eq = 'yf(x) = p1*x';
elseif strcmpi(params.fit_type, 'poly1')
    yf = fit(x, y, 'poly1');
    w_fit = [yf.p1 yf.p2];
    fit_eq = 'yf(x) = p1*x + p2';
elseif strcmpi(params.fit_type, 'poly2')
    yf = fit(x, y, 'poly2');
    w_fit = [yf.p1 yf.p2 yf.p3];
    fit_eq = 'yf(x) = p1*x^2 + p2*x + p3';
elseif strcmpi(params.fit_type, 'spline')
    yf = fit(x, y, 'spline');
    w_fit = 0;
    fit_eq = 'spline';
elseif strcmpi(params.fit_type, 'smoothingspline')
    yf = fit(x, y, 'smoothingspline', 'SmoothingParam', params.spline_smoothing_param);
    w_fit = 0;
    fit_eq = 'smoothingspline';
elseif strcmpi(params.fit_type, 'linearinterp')
    yf = fit(x, y, 'linearinterp');
    w_fit = 0;
    fit_eq = 'linearinterp';
end



end