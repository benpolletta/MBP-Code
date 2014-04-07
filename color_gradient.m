function color_order = color_gradient(no_colors,color_1,color_2)

% Produces a matrix (color_order) containing 3-digit colors, shading
% smoothly from color_1 to color_2.

color_order = [linspace(color_1(1),color_2(1),no_colors)' linspace(color_1(2),color_2(2),no_colors)' linspace(color_1(3),color_2(3),no_colors)'];