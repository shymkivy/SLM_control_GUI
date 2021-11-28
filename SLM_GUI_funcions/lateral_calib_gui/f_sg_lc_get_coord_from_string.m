function coord = f_sg_lc_get_coord_from_string(string1 , coord_tag)

loc1 = strfind(string1 ,coord_tag);
is_the_one = false(numel(loc1),1);
loc_num = zeros(numel(loc1),1);
for n_tag = 1:numel(loc1)
    current_loc = loc1(n_tag) + 1;
    
    if string1(current_loc) == '-'
        current_loc = current_loc + 1;
        sign1 = -1;
    else
        sign1 = 1;
    end
    
    if and(string1(current_loc) >= '0', string1(current_loc) <= '9')
        is_the_one(n_tag) = 1;
        
        start1 = current_loc;
        end1 = start1;
        while and(string1(end1+1) >= '0', string1(end1+1) <= '9')
            end1 = end1 + 1;
        end
        
        loc_num(n_tag) = str2double(string1(start1:end1))*sign1;
    end
end

if isempty(loc_num(is_the_one))
    coord = 0;
else
    coord = loc_num(is_the_one);
end

end