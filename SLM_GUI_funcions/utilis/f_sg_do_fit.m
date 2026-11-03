function [yf, w_fit, fit_eq] = f_sg_do_fit(x, y, params)
% simple fits use the toolbox if present, else base MATLAB (f_sg_fit_simple)

if strcmpi(params.fit_type, 'poly1_constrain_z0')
    w_fit = x\y;
    yf = @(n) w_fit*n;
    fit_eq = 'yf(x) = p1*x';
elseif strcmpi(params.fit_type, 'poly1')
    [yf, w_fit] = f_sg_fit_simple(x, y, 'poly1');
    fit_eq = 'yf(x) = p1*x + p2';
elseif strcmpi(params.fit_type, 'poly2')
    [yf, w_fit] = f_sg_fit_simple(x, y, 'poly2');
    fit_eq = 'yf(x) = p1*x^2 + p2*x + p3';
elseif strcmpi(params.fit_type, 'spline')
    [yf, w_fit] = f_sg_fit_simple(x, y, 'spline');
    fit_eq = 'spline';
elseif strcmpi(params.fit_type, 'smoothingspline')
    if ~f_sg_has_curvefit()
        error('Fit method smoothingspline needs the Curve Fitting Toolbox, which is not installed/licensed in MATLAB %s. Install it, or pick another fit method.', version('-release'));
    end
    yf = fit(x, y, 'smoothingspline', 'SmoothingParam', params.spline_smoothing_param);
    w_fit = 0;
    fit_eq = 'smoothingspline';
elseif strcmpi(params.fit_type, 'linearinterp')
    [yf, w_fit] = f_sg_fit_simple(x, y, 'linearinterp');
    fit_eq = 'linearinterp';
end



end
