function [wsum, tt] = hasl_gen_wsum( ld, pld, T1b, T1t)
    
    pld_num = length(pld);
    
    tt = (min(pld) * 1000 : max(pld) * 1000) / 1000;

    sig_sum = zeros(size(tt));
    sig_pld_sum = zeros(size(tt));
    
    for idx = 1 : pld_num
        
        pld_curr = pld(idx);
        ld_curr = ld(idx);
        
        exp_tt_T1b = exp( -tt ./ T1b);
        exp_pld_tt_T1t = exp( -max(0, pld_curr - tt) ./ T1t);
        exp_pld_ld_tt_T1t = exp( -max(0, pld_curr + ld_curr - tt) ./ T1t);
        
        sig = exp_tt_T1b .* (exp_pld_tt_T1t - exp_pld_ld_tt_T1t);
        
        sig_sum = sig_sum + sig;
        sig_pld_sum = sig_pld_sum + sig * pld_curr;
        
    end
    
    wsum = sig_pld_sum ./ sig_sum;
    
end