function img = auxil_img_trimedge(img, edge)

    img = img(edge+1:end-edge, edge+1:end-edge, :);

end