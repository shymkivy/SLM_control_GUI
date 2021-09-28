function f_SLM_write_lut(lut_array, fname_save)

%dlmwrite(fname_save ,lut_array,'delimiter','\t', 'newline', 'pc')

dlmwrite(fname_save ,lut_array,'delimiter',' ', 'newline', 'pc')
end