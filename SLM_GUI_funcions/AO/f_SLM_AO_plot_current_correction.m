function f_SLM_AO_plot_current_correction(app)

AO_wf = app.current_SLM_AO_Image;

if isstruct(AO_wf)
    Z = mean(app.current_SLM_coord.xyzp(:,3)*1e5);
    [dist1, idx] = min(abs(Z - [AO_wf.Z]));
    if dist1 <= 20
        AO_wf2 = AO_wf(idx).wf_out;
    else
        AO_wf2 = zeros(size(AO_wf(idx).wf_out));
    end
else
    AO_wf2 = AO_wf;
end

f_SLM_view_hologram_phase(app, AO_wf2);
title('Current AO wavefront');

end