function coord_corr_zcomp = f_sg_AO_coord_compensate_z(coord_corr, reg1)

coord_corr_zcomp = coord_corr;
comp_z1 = 0;
if isfield(reg1.AO_wf, 'fit_defocus_comp')
    if ~isnumeric(reg1.AO_wf.fit_defocus_comp)     % cfit or function handle; 0 = none
        comp_z1 = reg1.AO_wf.fit_defocus_comp(coord_corr_zcomp.xyzp(:,3));
    end
end
coord_corr_zcomp.xyzp(:,3) = coord_corr_zcomp.xyzp(:,3) + comp_z1;

end