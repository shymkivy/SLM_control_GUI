function reg_out = f_sg_get_reg_extra_deets(reg_in)

reg_out = reg_in;

defocus = f_sg_DefocusPhase2(reg_in);
                    
reg_out.defocus = defocus;
end