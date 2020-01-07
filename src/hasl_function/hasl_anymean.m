
function img_out = hasl_anymean(img_in, asl_para, state, loop_num)

img_size = size(img_in);

phase_num = img_size(end);
state_num = asl_para.State_Num;

img_out_size = img_size;
img_out_size(end) = state_num;

img_in = reshape(img_in, [], phase_num);

img_out = zeros(img_out_size);
img_out = reshape(img_out, [], state_num);

loop = 1: state_num;
loop = loop.';
state_array = repmat(loop, [1,loop_num]);

  state_idx = state_array(state);
  
 
  for idx = 1: state_num
      if isempty(find(state_idx == idx));
          error([mat2str(idx), ' is not in state_idx']);
      end
      
      mean_idx = find(state_idx ==idx);
      img_out(:, idx) = mean(img_in(:, mean_idx), 2);
  end
  
  img_out = reshape(img_out, img_out_size);
end