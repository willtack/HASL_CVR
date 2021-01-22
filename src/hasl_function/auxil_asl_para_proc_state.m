function asl_para = auxil_asl_para_proc_state(asl_para)
    
    if asl_para.PLD_Num == 1
        
        asl_para.State_Num = 2;
        
    elseif asl_para.PLD_Num == 3
        
        asl_para.State_Num = 5;
        
    elseif asl_para.PLD_Num == 7
        
        asl_para.State_Num = 9;
        
    end
    
end