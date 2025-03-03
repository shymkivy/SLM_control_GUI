function f_sg_pp_update_v_range(app)
%F_SG_PP_UPDATE_V_RANGE Summary of this function goes here
%   Detailed explanation goes here
if ~isempty(app.data.plot_im.CData)
    % because matlab is too stupid to realize that unsigned integers are
    % real, finite, increasing numbers (seriously, it will traceback if you
    % remove double)
    app.VMaxSlider.Limits = [double(min(app.data.plot_im.CData, [], 'all')), double(max(app.data.plot_im.CData, [], 'all'))];
    app.VMaxSlider.Value = app.VMaxSlider.Limits(2);
    f_sg_pp_vmax_cutoff(app, app.VMaxSlider.Value);
    app.VMaxSlider.Enable = true;
else
    app.VMaxSlider.Limits = [0, 100];
    app.VMaxSlider.Value = 100;
    app.VMaxSlider.Enable = false;
end

