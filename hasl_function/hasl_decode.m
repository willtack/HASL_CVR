function hasl_out = hasl_decode(hasl_in, asl_para)

    % % Prepare Decoding Matrix

    hasl_decode_mat1 = 1 * [...
        -1, 1;
        -1, 1];
    
    hasl_decode_mat3 = 1/8 * [... % 1st phase: control
        2, -3,  3,  3, -5;
        2, -3, -5,  3,  3;
        2, -3,  3, -5,  3;
        6, -9,  1,  1,  1];
    

    state_num = asl_para.State_Num;
    pld_num = asl_para.PLD_Num;
    
    hasl_decode_mat = [];

    if state_num == 2
        hasl_decode_mat = hasl_decode_mat1;
    elseif state_num == 5
        hasl_decode_mat = hasl_decode_mat3;
    end
    
    hasl_decode_mat = hasl_decode_mat';
    
    hasl_in_size = size(hasl_in);
    
    hasl_out_size = hasl_in_size;
    hasl_out_size(end) = pld_num + 1;
    
    hasl_in = reshape(hasl_in, [], state_num);
    
    hasl_out = hasl_in * hasl_decode_mat;
    
    hasl_out = reshape(hasl_out, hasl_out_size);
    
end
