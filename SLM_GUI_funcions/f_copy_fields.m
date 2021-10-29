function struct_out = f_copy_fields(struct_in, struct_source)

struct_out = struct_in;
fieldnames1 = fieldnames(struct_source);
for n_fl = 1:numel(fieldnames1)
    if ~isempty(struct_source.(fieldnames1{n_fl}))
        struct_out.((fieldnames1{n_fl})) = struct_source.(fieldnames1{n_fl});
    end
end

end