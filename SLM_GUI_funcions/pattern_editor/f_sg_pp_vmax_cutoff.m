function f_sg_pp_vmax_cutoff(app, value)
% Changes maximum value of the colorbar
    app.UIAxes.CLim = [app.UIAxes.CLim(1), value];
end

