function img_ttccbf = auxil_asl_calc_ttccbf(img_pw, img_m0, img_tt, img_msk, asl_para)
% 
% 
% FORMAT: img_cbf = auxil_asl_calc_ttccbf(img_pw, img_m0, img_msk, asl_para)
% 
% INPUT:
%   img_pw - perfusion weighted volume/slice array
%   img_m0 - proton density volume/slice
%   img_tt - transit time map [s]
%   img_msk - mask volume/slice
%   asl_para - ASL sequence parameter
%
% OUTPUT:
%   img_cbf - CBF map array
%                         
% -------------------------------------------------------------------------
% DESCRIPTION:  ...
% -------------------------------------------------------------------------
% EXAMPLE:      ...
% -------------------------------------------------------------------------
%                                           Jianxun Qu, @jianxun_qu@163.com
% ------------------------------------------------------------------------- 
    T1b = asl_para.T1b;
    T1t = asl_para.T1t;
    Lambda = asl_para.Lambda;
    Effeciency = asl_para.Effeciency;
    
    LD_arr = asl_para.LD_arr;
    PLD_arr = asl_para.PLD_arr;
    
    M0_Scale = asl_para.M0_Scale;
    
    % %     
%     numel_pw = numel(img_pw);
%     numel_m0 = numel(img_m0);
    
%     phase_num = numel_pw / numel_m0;

    pld_num = size(img_pw, 4);

    img_ttccbf = zeros(size(img_pw));
    
%     img_pw = reshape(img_pw, [], phase_num);
%     img_m0 = reshape(img_m0, [], 1);
%     img_tt = reshape(img_tt, [], 1);
%     
%     img_ttccbf = reshape(img_ttccbf, [], phase_num);
    msk_ind = find(img_msk > 0);  % return the index img_msk>0
    
    for pld_idx = 1 : pld_num
        
        pw_tmp = img_pw(:, :, :, pld_idx);
        
        ttccbf_tmp = img_ttccbf(:, :, :, pld_idx);
        
        ttc_factor = exp( -max(PLD_arr(pld_idx) - img_tt, 0) ./ T1t ) - exp( -max( LD_arr(pld_idx) + PLD_arr(pld_idx) - img_tt) ./ T1t );

        ttccbf_tmp(msk_ind) = 6000 * Lambda * exp( PLD_arr(pld_idx) / T1b ) ./ ...
                                  (2 * Effeciency * T1b .* ttc_factor(msk_ind)) .* ...
                                  (pw_tmp(msk_ind) ./ (img_m0(msk_ind) * M0_Scale) );
                              
        img_ttccbf(:, :, :, pld_idx) = ttccbf_tmp;

    end
    
%     img_ttccbf = reshape(img_ttccbf, size_pw);
    
end