% Default Decoding matrix will place min-PLD first and LL last

function hasl_out = auxil_hasl_decode(hasl_in, asl_para)

    % % Prepare Decoding Matrix

    hasl_decode_mat1 = [...
        -1, 1;
        -1, 1];
    
    hasl_decode_mat3 = 1/3 * [... % px28 version
        -1,  1,  1,  1, -2;
        -1,  1, -2,  1,  1;
        -1,  1,  1, -2,  1;
        -3,  3,  0,  0,  0];
    
    hasl_decode_mat7 = 1/16 * [... % px28 version
        -1,   4,  3,  3, -5,  3, -5, -5,  3;
        -1,   4, -5,  3,  3,  3,  3, -5, -5;
        -1,   4,  3, -5,  3,  3, -5,  3, -5;
        -1,   4, -5, -5, -5,  3,  3,  3,  3;
        -1,   4,  3,  3, -5, -5,  3,  3, -5;
        -1,   4, -5,  3,  3, -5, -5,  3,  3;
        -1,   4,  3, -5,  3, -5,  3, -5,  3;
        -16, 16,  0,  0,  0,  0,  0,  0,  0];
    
    state_num = asl_para.State_Num;
    pld_num = asl_para.PLD_Num;
    
    hasl_decode_mat = [];

    if state_num == 2
        hasl_decode_mat = hasl_decode_mat1;
    elseif state_num == 5
        hasl_decode_mat = hasl_decode_mat3;
    elseif state_num == 9
        hasl_decode_mat = hasl_decode_mat7;
    end
    
    hasl_decode_mat = hasl_decode_mat';
    
    hasl_in_size = size(hasl_in);
    
    hasl_out_size = hasl_in_size;
    hasl_out_size(end) = pld_num + 1;
    
    hasl_in = reshape(hasl_in, [], state_num);
    
    hasl_out = hasl_in * hasl_decode_mat;
    
    hasl_out = reshape(hasl_out, hasl_out_size);
    
end