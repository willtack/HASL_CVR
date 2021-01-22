
function img_out = auxil_asl_mean(img_in, asl_para)
    
    img_size = size(img_in);
    
    phase_num = img_size(end);
    state_num = asl_para.State_Num;
    
    img_out_size = img_size;
    img_out_size(end) = state_num;
    
    img_in = reshape(img_in, [], phase_num);
    
    img_out = zeros(img_out_size);
    img_out = reshape(img_out, [], state_num);
    
    for idx = 1: state_num
        
        img_out(:, idx) = mean(img_in(:, idx: state_num: end), 2);
        
    end
    
    img_out = reshape(img_out, img_out_size);
    
end