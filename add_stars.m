function add_stars(handle, t, logical, side_vec, c_order)

% Adds stars to a boundedline type plot. Logical is whether or not to add
% a star. Side vec is 0 for below & 1 for above. c_order is color of stars.

if any(logical ~= 0)
    
    [~, c] = size(logical);
    
    mult_vec = (1:c)*.1;
    
    hold on
    
    set(handle, 'NextPlot', 'add', 'ColorOrder', c_order)
    
    axis(handle, 'tight')
    
    yl = ylim(handle);
    
    yrange = diff(yl);
    
    add_vec = yl(1)*(side_vec == 0) + yl(2)*(side_vec == 1);
    
    mult_vec(side_vec == 0) = -.05*(1:sum(side_vec == 0));
    
    mult_vec(side_vec == 1) = .05*(1:sum(side_vec == 1));
    
    multiplier_vec = add_vec + mult_vec*yrange;
    
    logical_multiplier = ones(size(logical))*diag(multiplier_vec);
    
    plot(t, logical.*logical_multiplier, '*')
    
    ylim([min(multiplier_vec) max(multiplier_vec)])
    
else
    
    axis(handle, 'tight')
    
end


