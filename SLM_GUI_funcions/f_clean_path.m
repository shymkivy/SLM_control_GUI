function path_out = f_clean_path(path_in)

%path_parts=regexp(path_in,'\','split');
path_parts=regexp(path_in,filesep,'split');

num_parts = numel(path_parts);
dot_dot = false(num_parts,1);
for n_p = 1:num_parts
    dot_dot(n_p) = strcmpi(path_parts{n_p}, '..');
end

dot_dot2 = dot_dot;
for n_p = 2:num_parts
    if dot_dot(n_p)
        dot_dot2(n_p-1) = true;
    end
end

path_parts2 = path_parts;
path_parts2(dot_dot2) = [];

for n_p = 1:(numel(path_parts2)-1)
    path_parts2{n_p} = [path_parts2{n_p} '\'];
end

path_out = cat(2,path_parts2{:});

end