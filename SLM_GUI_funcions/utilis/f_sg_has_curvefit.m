function has_cf = f_sg_has_curvefit()
% true if the Curve Fitting Toolbox is installed and licensed (cached per session)
persistent has_cf1
if isempty(has_cf1)
    has_cf1 = ~isempty(ver('curvefit')) && license('test', 'Curve_Fitting_Toolbox');
end
has_cf = has_cf1;
end
