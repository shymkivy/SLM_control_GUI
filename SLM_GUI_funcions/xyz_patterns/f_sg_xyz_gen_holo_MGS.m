function SLM_phase = f_sg_xyz_gen_holo_MGS(app, coord, reg1)

app.SLM_ops = f_imageGen_load(app.SLM_ops);
app.SLM_ops.igObj.init(reg1.SLMm, reg1.SLMn);

app.SLM_ops.igObj.initHologramGenerator(app.GSnumiterationsEditField.Value);

GS_z_fac = app.GSzfactorEditField.Value;

phase_ptr = app.SLM_ops.igObj.generateHologram(coord.xyzp(:,1)*2,...
                                    -coord.xyzp(:,2)*2,...
                                    coord.xyzp(:,3)*GS_z_fac,....
                                    coord.I_targ1P,...
                                    numel(coord.W_est));

   
if ~app.SLM_ops.igObj.gen_val; fprintf('GS gen failed\n'); end

SLM_phase = f_sg_poiner_to_im(phase_ptr, reg1.SLMm, reg1.SLMn)-pi;

end