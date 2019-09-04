% ------------------------------------------------------------
%     ttcCBF Calculation for ASL    
% ------------------------------------------------------------
function img_ttccbf = hasl_ttccbf(img_pw, img_m0, img_tt, img_msk, asl_para)
    
    % % 
    T1b = asl_para.T1b;
    T1t = asl_para.T1t;
    Lambda = asl_para.Lambda;
    Effeciency = asl_para.Effeciency;
    
    LD_arr = asl_para.LD_arr;
    PLD_arr = asl_para.PLD_arr;
   
    M0_Scale = asl_para.M0_Scale;
    
    % %     

    pld_num = size(img_pw, 4);

    img_ttccbf = zeros(size(img_pw));

    msk_ind = find(img_msk > 0);  % return the index img_msk>0
    
    for pld_idx = 1 : pld_num
        
        pw_tmp = img_pw(:, :, :, pld_idx);
        
        ttccbf_tmp = img_ttccbf(:, :, :, pld_idx);
        
        ttc_factor = exp( -max(PLD_arr(pld_idx) - img_tt, 0) ./ T1t ) - exp( -max( LD_arr(pld_idx) + PLD_arr(pld_idx) - img_tt, 0) ./ T1t );

        ttccbf_tmp(msk_ind) = 6000 * Lambda * exp( PLD_arr(pld_idx) / T1b ) ./ (2 * Effeciency * T1b .* ttc_factor(msk_ind)) .* (pw_tmp(msk_ind) ./ (img_m0(msk_ind) * M0_Scale) );
                              
        img_ttccbf(:, :, :, pld_idx) = ttccbf_tmp;

    end

    
end