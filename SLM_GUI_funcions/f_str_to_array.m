function array_out = f_str_to_array(str_in)

if numel(str_in)
    out1 = split(str_in,':');

    num_items = numel(out1);
    if num_items > 1
        out2 = str2double(out1);
        if num_items == 2
            array_out =  out2(1):out2(2);
        elseif num_items == 3
            array_out =  out2(1):out2(2):out2(3);
        end
    else
        remove_ind = false(numel(str_in),1);
        remove_ind(strfind(str_in,'[')) = 1;
        remove_ind(strfind(str_in,']')) = 1;
        remove_ind(strfind(str_in,' ')) = 1;

        str_in2 = str_in;
        str_in2(remove_ind) = [];

        out1 = split(str_in2,',');
        array_out = str2double(out1);
    end
else
    array_out = 0;
    disp('Input is empty; used 0')
end

array_out = array_out(:);


end