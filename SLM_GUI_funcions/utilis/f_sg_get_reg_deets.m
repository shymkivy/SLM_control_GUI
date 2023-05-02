function region_obj_params = f_sg_get_reg_deets(app, name_tag)

if ~exist('name_tag', 'var')
    name_tag = app.CurrentregionDropDown.Value;
end
if isempty(name_tag)
    name_tag = app.CurrentregionDropDown.Value;
end

current_reg = app.region_list(strcmpi(name_tag, {app.region_list.reg_name}));

%app.SLMtypeDropDown.Value
reg_params_idx = f_sg_get_reg_params_idx(app, name_tag);
region_obj_params = app.region_obj_params(reg_params_idx);

% load objective params
objectives = app.SLM_ops.objectives(strcmpi(region_obj_params.obj_name, {app.SLM_ops.objectives.obj_name}));
region_obj_params = f_copy_fields(region_obj_params, objectives);

% get slm region
m = current_reg.height_range;
n = current_reg.width_range;

m_px = (1:app.SLM_ops.height)'/app.SLM_ops.height;
n_px = (1:app.SLM_ops.width)'/app.SLM_ops.width;

m_idx = logical((m_px>m(1)).*(m_px<=m(2)));
n_idx = logical((n_px>n(1)).*(n_px<=n(2)));

SLMm = sum(m_idx);
SLMn = sum(n_idx);

if isempty(region_obj_params)
    region_obj_params = app.SLM_ops.default_region_params;
    region_obj_params.phase_diameter = max([SLMm, SLMn]);
end

xlm = linspace(-SLMm/region_obj_params.phase_diameter, SLMm/region_obj_params.phase_diameter, SLMm);
xln = linspace(-SLMn/region_obj_params.phase_diameter, SLMn/region_obj_params.phase_diameter, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[~, RHO] = cart2pol(fX, fY);
holo_mask = true(SLMm, SLMn);

if app.regionZerooutsidephasediameterCheckBox.Value
    holo_mask(RHO>1) = 0;
end

if ~app.ApplyXYZcalibrationButton.Value  
    region_obj_params.xyz_offset = [0 0 0];
end

region_obj_params.SLMm = SLMm;
region_obj_params.SLMn = SLMn;
region_obj_params.m_idx = m_idx;
region_obj_params.n_idx = n_idx;
region_obj_params.holo_mask = holo_mask;
region_obj_params.objective_RI = app.ObjectiveRIEditField.Value;
region_obj_params.tube_length = app.TubelengthEditField.Value;
region_obj_params.sim_pixel_crosstalk = app.SimulatepixelcrosstalkCheckBox.Value;
region_obj_params.sim_smooth_std = f_str_to_array(app.XYsmoothstdpixEditField.Value);
end