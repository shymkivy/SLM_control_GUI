function f_SLM_initialize_GUI_params(app)
ops = app.SLM_ops;

%%
app.LUTDropDown.Items = app.lut_list;
app.LUTDropDown.Value = ops.lut_fname;

%% initialize region list
app.SelectRegionDropDown.Items = [app.region_list.name_tag];
app.GroupRegionDropDown.Items = [app.region_list.name_tag];
app.SelectRegionDropDownGH.Items = [app.region_list.name_tag];
app.AOregionDropDown.Items = [app.region_list.name_tag];

%%
app.LateralaffinetransformDropDown.Items = ops.lateral_calibration(:,1);
app.AxialcalibrationDropDown.Items = ops.axial_calibration(:,1);

%% update lut corrections
if ~isfield(app.region_list, 'lut_correction')
    app.region_list(1).lut_correction = [];
end
if ~isfield(app.region_list, 'lut_correction')
    for n_reg = 1:numel(app.region_list)
        app.region_list(n_reg).xyz_affine_tf_mat = diag(ones(3,1));
    end
end

f_SLM_reg_update(app);
f_SLM_compute_xyz_affine_tf_mat(app);

%% xyz table
% xyz_blank = table('Size', [0 6], 'VariableTypes', {'double', 'double','double', 'double', 'double', 'double'});
% xyz_blank.Properties.VariableNames = {'Pattern', 'Z', 'X', 'Y', 'NA', 'Weight'};
% app.GUI_ops.xyz_blank = xyz_blank;
f_SLM_pat_update(app, 1);
app.PatternDropDownCtr.Items = [{'None'}, app.xyz_patterns.name_tag];
app.PatternDropDownAI.Items = [{'None'}, app.xyz_patterns.name_tag];

%%
app.SLMheightEditField.Value = ops.height;
app.SLMwidthEditField.Value = ops.width;

app.ObjectiveMagXEditField.Value = ops.objective_mag;
app.ObjectiveNAEditField.Value = ops.objective_NA;
app.ObjectiveRIEditField.Value = ops.objective_RI;
app.WavelengthnmEditField.Value = ops.wavelength;
app.BeamdiameterpixEditField.Value = ops.beam_diameter;
app.SLMpresetoffsetXEditField.Value = ops.X_offset;
app.SLMpresetoffsetYEditField.Value = ops.Y_offset;
app.NIDAQdeviceEditField.Value = ops.NI_DAQ_dvice;
app.DAQcounterchannelEditField.Value = ops.NI_DAQ_counter_channel;
app.DAQAIchannelEditField.Value = ops.NI_DAQ_AI_channel;

% AO dropdown
app.AOcorrectionfilesDropDown.Items  = app.SLM_ops.zernike_file_names;
if ~isempty(app.SLM_ops.zernike_file_names)
    app.AOcorrectionfilesDropDown.Value = app.SLM_ops.zernike_file_names{1};
end

%%
% blank
app.BlankPixelValueEditField.Value = 0;

% Fresnel lens
app.FresCenterXEditField.Value = app.SLM_ops.width/2;
app.FresCenterYEditField.Value = app.SLM_ops.height/2;
app.FresRadiusEditField.Value = app.SLM_ops.height/2;
app.FresPowerEditField.Value = 1;
app.FresCylindricalCheckBox.Value = 1;
app.FresHorizontalCheckBox.Value = 0;

% Blazed grating
app.BlazPeriodEditField.Value = 128;
app.BlazIncreasingCheckBox.Value = 1;
app.BlazHorizontalCheckBox.Value = 0;

% Stripes
app.StripePixelPerStripeEditField.Value = 8;
app.StripePixelValueEditField.Value = 0;
app.StripeGrayEditField.Value = 255;

% zernike
app.CenterXEditField.Value = floor(app.SLM_ops.width/2);
app.CenterYEditField.Value = floor(app.SLM_ops.height/2);
app.RadiusEditField.Value = min([app.SLM_ops.height, app.SLM_ops.height])/2;

%%
% Multiplane imaging
app.UIImagePhaseTable.Data = table();

% AO zernike table
app.ZernikeListTable.Data = table();
f_SLM_AO_fill_modes_table(app);
f_SLM_LUT_update_total_frames(app);

% current coord initialize
app.current_SLM_coord = f_SLM_mpl_get_coords(app, 'zero');
app.UITablecurrentcoord.Data = app.current_SLM_coord.xyzp;

% initialize af matrix
app.ApplyXYZcalibrationButton.Value = 1;
f_SLM_apply_xyz_calibration(app);

% initialize blank image
app.SLM_blank_im = zeros(app.SLM_ops.height, app.SLM_ops.width);
app.SLM_blank_pointer = f_SLM_initialize_pointer(app);
app.SLM_Image_pointer.Value = f_SLM_im_to_pointer(zeros(app.SLM_ops.height, app.SLM_ops.width));

% initialize X offset image
app.SLM_X_offset_im_pointer = f_SLM_initialize_pointer(app);
coords = f_SLM_mpl_get_coords(app, 'zero');
coords.xyzp = [app.SLM_ops.X_offset, 0, 0];
app.SLM_X_offset_im = f_SLM_gen_holo_multiplane_image(app, coords);
app.SLM_X_offset_im_pointer.Value = f_SLM_im_to_pointer(app.SLM_X_offset_im);

% initialize ref image
app.SLM_ref_im_pointer = f_SLM_initialize_pointer(app);
coords = f_SLM_mpl_get_coords(app, 'zero');
coords.xyzp = [app.SLM_ops.ref_offset, 0, 0;...
               -app.SLM_ops.ref_offset, 0, 0;...
                0, app.SLM_ops.ref_offset, 0;...
                0,-app.SLM_ops.ref_offset, 0];
app.SLM_ref_im = f_SLM_gen_holo_multiplane_image(app, coords);
app.SLM_ref_im_pointer.Value = f_SLM_im_to_pointer(app.SLM_ref_im);

% initialize other pointers
app.SLM_Image = zeros(app.SLM_ops.height,app.SLM_ops.width);
app.SLM_Image_pointer = f_SLM_initialize_pointer(app);
app.SLM_Image_plot = imagesc(app.UIAxesGenerateHologram, app.SLM_Image);
axis(app.UIAxesGenerateHologram, 'tight');
axis(app.UIAxesGenerateHologram, 'equal');
caxis(app.UIAxesGenerateHologram, [0 2*pi]);

app.SLM_Image_gh_preview = app.SLM_Image;

app.ViewHologramImage_pointer = f_SLM_initialize_pointer(app);

f_SLM_AO_generate_AO_image(app);  

% initialize DAQ
f_SLM_initialize_DAQ(app);

%

end