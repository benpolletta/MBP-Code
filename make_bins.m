function [bin_edges, bin_centers] = make_bins(edge_1, edge_2, no_bins, spacing)

if strcmp(spacing, 'linear') || isempty(spacing)
   
    bin_edges = linspace(edge_1, edge_2, no_bins + 1);
    
    bin_centers = (bin_edges(1:(end - 1)) + bin_edges(2:end))/2;
    
elseif strcmp(spacing, 'log')

    bin_edges = log_space(edge_1, edge_2, [], no_bins + 1);
    
    bin_edge_powers = log(bin_edges);
    
    bin_center_powers = (bin_edge_powers(1:(end - 1)) + bin_edge_powers(2:end))/2;
    
    bin_centers = exp(bin_center_powers);
    
end
