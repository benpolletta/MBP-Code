function [sig_higher, sig_lower] = find_sig(centroid, spread)
    
    bounds = nan([size(centroid), 2]);

    for i = 1:2
    
        bounds(:, :, i) = repmat(centroid(:, i), 1, 2) + [spread(:, i), -spread(:, i)];
    
    end

    sig_higher = bounds(:, 2, 1) - bounds(:, 1, 2) > 0;
    
    sig_lower = bounds(:, 2, 2) - bounds(:, 1, 1) > 0;

end