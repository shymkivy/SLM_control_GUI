function reg_out = f_sg_get_reg_extra_deets(reg_in)

reg_out = reg_in;


defocus = f_sg_DefocusPhase(reg_in.SLMm, reg_in.SLMn,...
                        reg_in.effective_NA,...
                        reg_in.objective_RI,...
                        reg_in.wavelength*1e-9);

                    
reg_out.defocus = defocus;
end