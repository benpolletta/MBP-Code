function [test, colors, p_tag] = test_p_vals(p_vals, p_val, varargin)

% Assigns colors to p-values based on significance level. 
% * p_val contains the edges of the significance level bins. 
% * p_vals is an m by n vector of p_vals.
% * colors_in is an d by a n by 3 matrix containing the extremes of the color
%   spectra to be assigned to each column of p-vals (brighter = more
%   significant).
%
% Usually used in combination with add_stars_one_line, as in
% make_all_band_figures_spectrum:
%       
% [test, colors, p_tag] = test_p_vals(p_vals, p_val, [1 .5 0; 1 0 0]);
% 
% add_stars_one_line(gca, (1:freq_limit)', logical(test(:, :, 1)), 0, colors(:, :, 1))
% 
% add_stars_one_line(gca, (1:freq_limit)', logical(test(:, :, 2)), 1, colors(:, :, 2))

no_ps = length(p_val);

no_tests = size(p_vals, 2);

test = nan([size(p_vals, 1), no_ps, no_tests]);

colors = nan(no_ps, 3, no_tests);
    
for t = 1:no_tests
    
    test(:, 1, t) = p_vals(:, t) < p_val(1);
    
    for p = 2:no_ps
    
        test(:, p, t) = p_vals(:, t) >= p_val(p - 1) & p_vals(:, t) < p_val(p);
    
    end

    colors(:, :, t) = flipud(color_gradient(no_ps, .5*colors_in(t, :), colors_in(t, :)));
    
end

if isscalar(p_val)
    
    p_tag = sprintf('_p%g', p_val);
    
else
    
    p_tag = sprintf('_p%gto%g', p_val(1), p_val(end));

end

end