% ------------------------------------------------------------
%     CBF Calculation for ASL    
% ------------------------------------------------------------
function img_cbf = hasl_cbf(img_pw, img_m0, img_msk, asl_para) % ld, pld is array
    
    % % Extract parameter from asl_para     

    T1b = asl_para.T1b;
    Lamida = asl_para.Lamida;
    Effeciency = asl_para.Effeciency;
    
    LD_arr = asl_para.LD_arr;
    PLD_arr = asl_para.PLD_arr;
    
    M0_Scale = asl_para.M0_Scale;
    
%     numel_pw = numel(img_pw);
%     numel_m0 = numel(img_m0);

    pld_num = size(img_pw, 4);
    
    img_cbf = zeros(size(img_pw));

%     img_pw = reshape(img_pw, [], pld_num);
%     img_m0 = reshape(img_m0, [], 1);
%     img_cbf = reshape(img_cbf, [], pld_num);

    msk_ind = find(img_msk > 0);

    for idx = 1: pld_num  % calculate CBF in each phase
        
        pw_tmp = img_pw(:, :, :, idx);
        
        cbf_tmp = img_cbf(:, :, :, idx);

        cbf_tmp(msk_ind) = 6000 * Lamida * exp( PLD_arr(idx) / T1b ) /...
                           (2 * Effeciency * T1b * ( 1 - exp( -LD_arr(idx) / T1b) )) *...
                           pw_tmp(msk_ind) ./ ( img_m0(msk_ind) * M0_Scale );

        img_cbf(:, :, :, idx) = cbf_tmp;
        
    end
    
%     img_cbf = reshape(img_cbf, size(img_pw)); 

end