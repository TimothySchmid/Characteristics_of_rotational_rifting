function c_map = fct_color_map(thresh_val)
% Binary red-white colormap for thresholding

        xt = thresh_val*100;
        
        c_vec1     = [linspace(1,1,100-xt) linspace(1,1,xt)]';
        c_vec2     = [linspace(0,0,100-xt) linspace(1,1,xt)]';
        c_vec3     = [linspace(0,0,100-xt) linspace(1,1,xt)]';
        
        c_map      = flipud([c_vec1, c_vec2, c_vec3]);
end

