function nii_path_tgt = auxil_nii_phase_extract(nii_path_src, nii_filename_tgt, phase_idx)

    nii = load_untouch_nii(nii_path_src);
    
    nii.img = nii.img(:,:,:,phase_idx);
    nii.hdr.dime.dim(5) = length(phase_idx);
    nii.hdr.dime.glmin = min(nii.img(:));
    nii.hdr.dime.glmax = max(nii.img(:));
    
    [nii_folder, ~, ~] = fileparts(nii_path_src);
    
    [~, nii_filename_tgt, ~] = fileparts(nii_filename_tgt);
    
    nii_path_tgt = fullfile(nii_folder, [nii_filename_tgt, '.nii']);
    save_untouch_nii(nii, nii_path_tgt);

end