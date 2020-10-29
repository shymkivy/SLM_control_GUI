function f_SLM_gh_cross(app)

% get roi
[m, n] = f_SLM_gh_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

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

holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) = cross_im;

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;


end