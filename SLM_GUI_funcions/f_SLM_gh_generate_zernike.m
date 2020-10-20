function f_SLM_gh_generate_zernike(app)

% get roi
[m, n] = f_SLM_gh_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

pointer = libpointer('uint8Ptr', zeros(SLMn*SLMm,1));

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

holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) = f_SLM_poiner_to_im(app, pointer, SLMm, SLMn);

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;
end