function img = auxil_img_chop(img, edge)

    img = img(edge+1:end-edge, edge+1:end-edge, :);

end