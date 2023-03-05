function f_waitbar_close(wb)

if wb.new_fig
    close(wb.h);
else
    close(wb.handlew);
end

end