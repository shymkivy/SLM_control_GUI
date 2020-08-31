function f_SLM_generate_zernike(app)

% first generate zernike
% void Generate_Zernike(unsigned char* Array, int width, int height, int CenterX, int
% CenterY, int Radius, double Piston, double TiltX, double TiltY, double Power, double
% AstigX, double AstigY, double ComaX, double ComaY, double PrimarySpherical, double
% TrefoilX, double TrefoilY, double SecondaryAstigX, double SecondaryAstigY, double
% SecondaryComaX, double SecondaryComaY, double SecondarySpherical, double
% TetrafoilX, double TetrafoilY, double TertiarySpherical, double QuaternarySpherical);



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


calllib('ImageGen', 'Generate_Zernike', app.SLM_Image_pointer, app.SLM_ops.width, app.SLM_ops.height,...
                        centerX, centerY, Radius, piston, TiltX, TiltY, Power, AstigX, AstigY,...
                        ComaX, ComaY, PrimarySpherical, TrefoilX, TrefoilY,...
                        SecondaryAstigX, SecondaryAstigY,...
                        SecondaryComaX, SecondaryComaY, SecondarySpherical,...
                        TetrafoilX, TetrafoilY, TertiarySpherical,...
                        QuaternarySpherical);

% image_slm = single(reshape(app.SLM_Image_pointer.Value, [app.SLM_ops.width,app.SLM_ops.height]));
% figure; imagesc(image_slm');
%                     
                    
f_SLM_plot_SLM_image(app);
end