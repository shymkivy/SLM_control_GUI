function lut_array = f_SLM_read_lut(fname)


%lut_array = load(fname);

fileID = fopen(fname);
%[filename,permission,machinefmt,encoding] = fopen(fileID);
tline = fgets(fileID);
if sum(tline==9) 
    break1 = 9; % tab (from linear lut) ASCII CODE
elseif sum(tline==32)
    break1 = 32; % space (from custom lut) ASCII CODE
end
done1 = 0;
num_rows = 1;
while ~done1
    tline = fgets(fileID);
    if tline~=-1
        num_rows = num_rows+1;
    else
        done1 = 1;
    end
end
fclose(fileID);

lut_array = zeros(num_rows,2);
fileID = fopen(fname);
for n_row = 1:num_rows
    tline = fgets(fileID);
    end1 = find(tline == char(break1));
    end2 = find(tline == char(13)); % 13, 10 (carriage return, line feed)
    lut_array(n_row,1) = str2double(tline(1:end1-1));
    if ~isempty(end2)
        lut_array(n_row,2) = str2double(tline(end1+1:end2-1));
    else
        lut_array(n_row,2) = str2double(tline(end1+1:end));
    end
end
fclose(fileID);


end