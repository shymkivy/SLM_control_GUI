function holo_phase = f_sg_gh_gen_image(app, pattern, reg1)


app.SLM_ops = f_imageGen_load(app.SLM_ops);
app.SLM_ops.igObj.init(reg1.SLMm, reg1.SLMn);

if strcmpi(pattern, 'piston')
    pointer = app.SLM_ops.igObj.generateSolid(app.BlankPixelValueEditField.Value);

elseif strcmpi(pattern, 'blazed')
    pointer = app.SLM_ops.igObj.generateGrating(app.BlazPeriodEditField.Value,...
                                                app.BlazIncreasingCheckBox.Value,...
                                                app.BlazHorizontalCheckBox.Value);
    if app.BlazReverseCheckBox.Value
        pointer.Value = max(pointer.Value) - pointer.Value;
    end
elseif strcmpi(pattern, 'fresnel')
    pointer = app.SLM_ops.igObj.generateFresnel(app.FresCenterXEditField.Value,...
                                                app.FresCenterYEditField.Value,...
                                                app.FresRadiusEditField.Value,...
                                                app.FresPowerEditField.Value,...
                                                app.FresCylindricalCheckBox.Value,...
                                                app.FresHorizontalCheckBox.Value);

elseif strcmpi(pattern, 'stripes')
    pointer = app.SLM_ops.igObj.generateStripe(app.StripePixelValueEditField.Value,...
                                                app.StripeGrayEditField.Value,...
                                                app.StripePixelPerStripeEditField.Value, ...
                                                app.HorizontalstripeCheckBox.Value);

elseif strcmpi(pattern, 'zernike')
    pointer = app.SLM_ops.igObj.generateZernike(int32(app.CenterXEditField.Value), int32(app.CenterYEditField.Value),...
            int32(app.RadiusEditField.Value), app.PistonEditField.Value,...
            app.TiltXEditField.Value, app.TiltYEditField.Value,...
            app.PowerEditField.Value,...
            app.AstigXEditField.Value, app.AstigYEditField.Value,...
            app.ComaXEditField.Value, app.ComaYEditField.Value,...
            app.PrimarySphericalEditField.Value,...
            app.TrefoilXEditField.Value, app.TrefoilYEditField.Value,...
            app.SecondaryAstigXEditField.Value, app.SecondaryAstigYEditField.Value,...
            app.SecondaryComaXEditField.Value, app.SecondaryComaYEditField.Value,...
            app.SecondarySphericalEditField.Value,...
            app.TetrafoilXEditField.Value, app.TetrafoilYEditField.Value,...
            app.TertiarySphericalEditField.Value,...
            app.QuaternarySphericalEditField.Value);
elseif strcmpi(pattern, 'cross')
    pointer = app.SLM_ops.igObj.    init_pointer();

    max_dim = max(reg1.SLMn, reg1.SLMm);
    xlm = linspace(-reg1.SLMm/max_dim, reg1.SLMm/max_dim, reg1.SLMm);
    xln = linspace(-reg1.SLMn/max_dim, reg1.SLMn/max_dim, reg1.SLMn);
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
    
    holo_phase = (cross_im)/256*2*pi;

    pointer.Value = f_sg_im_to_pointer(holo_phase);
else
    pointer = app.SLM_ops.igObj.init_pointer();
end


holo_phase = f_sg_poiner_to_im(pointer, reg1.SLMm, reg1.SLMn);

end