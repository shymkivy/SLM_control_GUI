function f_sg_initialize_default_regobj_params(app)

idx = 1;

default_objectives(idx).obj_name = 'default';
default_objectives(idx).FOV_size = 500;

default_region_list(idx).reg_name = 'Full SLM';
default_region_list(idx).height_range = [0, 1];
default_region_list(idx).width_range = [0, 1];

% default_region_params(idx).obj_name = default_objectives.obj_name;
% default_region_params(idx).SLM_name = app.SLM_ops.SLM_type;
% default_region_params(idx).reg_name = default_region_list.reg_name;
default_region_params(idx).phase_diameter = [];
default_region_params(idx).zero_outside_phase_diameter = true;
default_region_params(idx).beam_diameter = [];
default_region_params(idx).wavelength = 940;
default_region_params(idx).effective_NA = .5;
default_region_params(idx).lut_correction_fname = [];
default_region_params(idx).xyz_affine_tf_fname = [];
default_region_params(idx).AO_correction_fname = [];
default_region_params(idx).point_weight_correction_fname = [];
default_region_params(idx).lut_correction_data = [];
default_region_params(idx).xyz_affine_tf_mat = [];
default_region_params(idx).AO_wf = [];
default_region_params(idx).pw_corr_data = [];
default_region_params(idx).xyz_offset = [0 0 0];
default_region_params(idx).xy_over_z_offset = [0 0]; % axial beam offset by z
default_region_params(idx).zero_order_supp_phase = 0; % in radians % 224 from [0 - 255] 
default_region_params(idx).zero_order_supp_w = 0;
default_region_params(idx).beam_dump_xy = [0 0]; % axial beam offset by z

app.SLM_ops.default_objectives = default_objectives;
app.SLM_ops.default_region_list = default_region_list;
app.SLM_ops.default_region_params = default_region_params;

end