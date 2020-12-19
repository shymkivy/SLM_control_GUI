function [holo_pointers, zernike_scan_sequence] = f_SLM_AO_make_zernike_pointers(app, AO_wf)

%%
[m_idx, n_idx, ~,  reg1] = f_SLM_get_reg_deets(app, app.CurrentregionDropDown.Value);

SLMm = sum(m_idx);
SLMn = sum(n_idx);
beam_width = app.BeamdiameterpixEditField.Value;
xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol( fX, fY );

%% create pointers
zernike_table = app.ZernikeListTable.Data;

% generate all polynomials
num_modes = size(zernike_table,1);
all_modes = zeros(SLMm, SLMn, num_modes);
for n_mode = 1:num_modes
    Z_nm = f_SLM_zernike_pol(rho, theta, zernike_table(n_mode,2), zernike_table(n_mode,3));
    if app.AOzerooutsideunitcircCheckBox.Value
        Z_nm(rho>1) = 0;
    end
    all_modes(:,:,n_mode) = Z_nm;
end

% generate scan sequence
all_patterns = cell(num_modes,1);
for n_mode = 1:num_modes
    if zernike_table(n_mode,7)
        weights1 = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
        temp_patterns = [ones(numel(weights1),1)*zernike_table(n_mode,1), weights1']; 
        if app.InsertrefimageinscansCheckBox.Value
            all_patterns{n_mode} = [999,999; temp_patterns];
        else
            all_patterns{n_mode} = temp_patterns;
        end
    end
end

zernike_scan_sequence = cat(1,all_patterns{:});
zernike_scan_sequence = repmat(zernike_scan_sequence,app.ScanspermodeEditField.Value,1);
num_scans = size(zernike_scan_sequence,1);
if app.ShufflemodesCheckBox.Value
    zernike_scan_sequence = zernike_scan_sequence(randsample(num_scans,num_scans),:);
end

init_image = app.SLM_Image;

if app.InsertrefimageinscansCheckBox.Value
    ref_coords = f_SLM_mpl_get_coords(app, 'zero');
    ref_coords.xyzp = [app.SLM_ops.ref_offset, 0, 0;...
                   -app.SLM_ops.ref_offset, 0, 0;...
                    0, app.SLM_ops.ref_offset, 0;...
                    0,-app.SLM_ops.ref_offset, 0];
    ref_im = f_SLM_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value);
end

% generate pointers
holo_pointers = cell(num_scans,1);
for n_plane = 1:num_scans
    n_mode = zernike_scan_sequence(n_plane,1);
    n_weight = zernike_scan_sequence(n_plane,2);
    holo_im = init_image;
    if n_mode == 999
        holo_im(m_idx,n_idx) = ref_im;
    else
        holo_im(m_idx,n_idx) = init_image(m_idx,n_idx).*exp(1i*(all_modes(:,:,n_mode)*n_weight));
    end

    if app.ApplyAOcorrectionButton.Value
        if ~isempty(AO_wf)
            holo_im = holo_im.*exp(1i*(AO_wf));
        end
    end

    %figure; imagesc(holo_im); title(['mode=' num2str(n_mode) ' weight=' num2str(n_weight)]);
    holo_phase = angle(holo_im) + pi;
    holo_pointers{n_plane} = f_SLM_initialize_pointer(app);
    holo_pointers{n_plane}.Value = f_SLM_im_to_pointer(holo_phase);
end

end