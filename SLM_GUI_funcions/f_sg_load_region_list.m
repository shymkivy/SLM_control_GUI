function f_sg_load_region_list(app)
ops = app.SLM_ops;

region_list = ops.default_region_list;
if isfield(ops, 'region_list')
    if ~isempty(ops.region_list)
        region_list = ops.region_list;
    end
end

if isfield(ops, 'regions_use')
    if ~isempty(ops.regions_use)
        is_reg = false(numel(region_list),1);
        for n_reg = 1:numel(region_list)
            is_reg(n_reg) = sum(strcmpi(region_list(n_reg).reg_name, ops.regions_use));
        end
        region_list(~is_reg) = [];
    end
end

if isempty(region_list)
    region_list = ops.default_region_list;
end

app.region_list = region_list;
app.SelectRegionDropDown.Items = {region_list.reg_name};
app.CurrentregionDropDown.Items = {region_list.reg_name};

app.SelectRegionDropDown.Value = region_list(1).reg_name;
app.CurrentregionDropDown.Value = region_list(1).reg_name;

end