function f_sg_load_load_regobj_params(app)
ops = app.SLM_ops;

reg_obj_params = ops.region_params;
rop_to_use = false(numel(reg_obj_params),1);
for n_p = 1:numel(reg_obj_params)
    if strcmpi(reg_obj_params(n_p).SLM_name, ops.SLM_type)
        if sum(strcmpi(reg_obj_params(n_p).reg_name, {app.region_list.reg_name}))
            rop_to_use(n_p) = 1;
        end
    end
end

if sum(rop_to_use)
    app.region_obj_params = reg_obj_params(rop_to_use);
else
    default_roparams.obj_name = ops.default_objectives.obj_name;
    default_roparams.SLM_name = ops.SLM_type;
    default_roparams.reg_name = ops.default_region_list.reg_name;
    default_roparams = f_copy_fields(default_roparams, ops.default_region_params);
    app.region_obj_params = default_roparams;
end

end