function f_waitbar_update(wb, fraction_comp, new_text)

if ~exist('new_text', 'var')
    add_text = 0;
else
    add_text = 1;
end

if wb.new_fig
    if add_text
        waitbar(fraction_comp,wb.h, new_text);
    else
        waitbar(fraction_comp,wb.h);
    end
else
    wb.handlew.Value = fraction_comp;
end

end