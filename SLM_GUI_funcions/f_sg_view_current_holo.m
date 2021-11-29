function f_sg_view_current_holo(app)

text1 = {'on', 'off'};

holo_phase = app.SLM_phase;
% corrections already added
%holo_phase = f_sg_AO_add_correction(holo_phase, app.current_SLM_AO_Image);
f_sg_view_hologram_phase(app, holo_phase);
title(sprintf('Current uploaded phase, AO %s', text1{2-app.ApplyAOcorrectionButton.Value}));

end