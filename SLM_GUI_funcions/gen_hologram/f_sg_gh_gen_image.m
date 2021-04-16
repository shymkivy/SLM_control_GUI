function pointer = f_sg_gh_gen_image(app, pattern, SLMm, SLMn)

pointer = libpointer('uint8Ptr', zeros(SLMn*SLMm,1));

if strcmpi(pattern, 'piston')
    calllib('ImageGen', 'Generate_Solid',...
            pointer,...
            SLMn, SLMm,...
            app.BlankPixelValueEditField.Value);
    
elseif strcmpi(pattern, 'blazed')
    calllib('ImageGen', 'Generate_Grating',...
            pointer,...
            SLMn, SLMm,...
            app.BlazPeriodEditField.Value,...
            app.BlazIncreasingCheckBox.Value,...
            app.BlazHorizontalCheckBox.Value);
    if app.BlazReverseCheckBox.Value
        pointer.Value = max(pointer.Value) - pointer.Value;
    end
elseif strcmpi(pattern, 'fresnel')
    calllib('ImageGen', 'Generate_FresnelLens',...
            pointer,...
            SLMn, SLMm,...
            app.FresCenterXEditField.Value,...
            app.FresCenterYEditField.Value,...
            app.FresRadiusEditField.Value,...
            app.FresPowerEditField.Value,...
            app.FresCylindricalCheckBox.Value,...
            app.FresHorizontalCheckBox.Value);
elseif strcmpi(pattern, 'stripes')
    calllib('ImageGen', 'Generate_Stripe',...
            pointer,...
            SLMn, SLMm,...
            app.StripePixelValueEditField.Value,...
            app.StripeGrayEditField.Value,...
            app.StripePixelPerStripeEditField.Value);
elseif strcmpi(pattern, 'zernike')
    centerX = int32(app.CenterXEditField.Value);    % int
    centerY = int32(app.CenterYEditField.Value);    % int
    Radius = int32(app.RadiusEditField.Value);      % int
    piston = app.PistonEditField.Value;             % double for all remaining
    TiltX = app.TiltXEditField.Value;
    TiltY = app.TiltYEditField.Value;
    Power = app.PowerEditField.Value;
    AstigX = app.AstigXEditField.Value;
    AstigY = app.AstigYEditField.Value;
    ComaX = app.ComaXEditField.Value;
    ComaY = app.ComaYEditField.Value;
    PrimarySpherical = app.PrimarySphericalEditField.Value;
    TrefoilX = app.TrefoilXEditField.Value;
    TrefoilY = app.TrefoilYEditField.Value;
    SecondaryAstigX = app.SecondaryAstigXEditField.Value;
    SecondaryAstigY = app.SecondaryAstigYEditField.Value;
    SecondaryComaX = app.SecondaryComaXEditField.Value;
    SecondaryComaY = app.SecondaryComaYEditField.Value;
    SecondarySpherical = app.SecondarySphericalEditField.Value;
    TetrafoilX = app.TetrafoilXEditField.Value;
    TetrafoilY = app.TetrafoilYEditField.Value;
    TertiarySpherical = app.TertiarySphericalEditField.Value;
    QuaternarySpherical = app.QuaternarySphericalEditField.Value;


    calllib('ImageGen', 'Generate_Zernike',...
            pointer,...
            SLMn, SLMm,...
            centerX, centerY, Radius, piston,...
            TiltX, TiltY, Power, AstigX, AstigY,...
            ComaX, ComaY, PrimarySpherical, TrefoilX, TrefoilY,...
            SecondaryAstigX, SecondaryAstigY,...
            SecondaryComaX, SecondaryComaY, SecondarySpherical,...
            TetrafoilX, TetrafoilY, TertiarySpherical,...
            QuaternarySpherical);
elseif strcmpi(pattern, 'cross')
    max_dim = max(SLMn,SLMm);
    xlm = linspace(-SLMm/max_dim, SLMm/max_dim, SLMm);
    xln = linspace(-SLMn/max_dim, SLMn/max_dim, SLMn);
    [fX, fY] = meshgrid(xln, xlm);
    [theta, ~] = cart2pol(fX, fY);

    ref_ang = app.CrossAngleEditField.Value;

    ref_ang1 = angle(exp(1i*ref_ang));
    ref_ang2 = angle(exp(1i*(ref_ang + pi/2)));
    ref_ang3 = angle(exp(1i*(ref_ang + pi)));
    ref_ang4 = angle(exp(1i*(ref_ang + 3*pi/2)));

    if ref_ang1 < ref_ang2
        pat1 = (theta > ref_ang1).*(theta < ref_ang2);
    else
        pat1 = (theta > ref_ang1)+(theta < ref_ang2);
    end

    if ref_ang3 < ref_ang4
        pat2 = (theta > ref_ang3).*(theta < ref_ang4);
    else
        pat2 = (theta > ref_ang3)+(theta < ref_ang4);
    end

    cross_im_ind = pat1+pat2;

    cross_im = cross_im_ind;
    cross_im(cross_im_ind == 0) = app.CrossPixelValueEditField.Value;
    cross_im(cross_im_ind == 1) = app.CrossGrayEditField.Value;
    
    pointer.Value = reshape(uint8((rot90(cross_im, 3))), [],1);
end

end