function f_sg_view_hologram_fft(app, holo_image, defocus_dist)

    dims = size(holo_image);
    siz = max(dims);

    phase_sq = zeros(siz,siz);

    % beam shape
    Lx = linspace(-(siz-1)/2,(siz-1)/2,siz);
    [c_X, c_Y] = meshgrid(Lx, Lx);

    sigma = app.BeamdiameterpixEditField.Value; 			% beam waist/2
    x0 = 0;                 % beam center location
    y0 = 0;                 % beam center location
    A = 1;                  % peak of the beam 
    res = ((c_X-x0).^2 + (c_Y-y0).^2)./(2*sigma^2);
    pupil_amp = A  * exp(-res);

    pupil_mask = phase_sq;
    pupil_mask((1 + (siz - dims(1))/2):(siz - (siz - dims(1))/2),(1 + (siz - dims(2))/2):(siz - (siz - dims(2))/2)) = 1;

    pupil_amp = pupil_amp.*pupil_mask;

    defocus = f_sg_DefocusPhase_YS(siz,...
                            siz,...
                            app.EffectiveNAEditField.Value,...
                            app.ObjectiveRIEditField.Value,...
                            app.WavelengthnmEditField.Value*1e-9);

    defocus = defocus .* pupil_mask;

    holo_image1 = phase_sq;
    holo_image1((1 + (siz - dims(1))/2):(siz - (siz - dims(1))/2),(1 + (siz - dims(2))/2):(siz - (siz - dims(2))/2)) = holo_image;

    SLM_complex_wave=pupil_amp.*(holo_image1./exp(1i.*(defocus_dist.*defocus)));

%             phase=angle(SLM_complex_wave)+pi;
%             amp = abs(SLM_complex_wave);

    im1 = fftshift(fft2(SLM_complex_wave));
    im1_amp = abs(im1)/sum(abs(SLM_complex_wave(:)));

    if app.fftampsquaredCheckBox.Value
        im1_amp = im1_amp.^2;
    end

%             figure; imagesc(phase)
%             figure; imagesc(amp)
%             figure; imagesc(abs(im1))

    figure;
    app.hologram_fig_plot = newplot;
    imagesc(app.hologram_fig_plot,im1_amp);
    axis(app.hologram_fig_plot, 'image');
    caxis(app.hologram_fig_plot, [0 1]);
    colorbar(app.hologram_fig_plot, 'eastoutside');
    if app.fftzoomed20xCheckBox.Value
        xlim(app.hologram_fig_plot,[siz/2-siz/20 siz/2+siz/20]);
        ylim(app.hologram_fig_plot,[siz/2-siz/20 siz/2+siz/20]);
    end
end