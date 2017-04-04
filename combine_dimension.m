function combined_data = combine_dimension(window_data_cell, dimension_combined, combination_order)

    no_dims = length(size(window_data_cell{1}));
    
    indices = cell(1, no_dims);
    
    indices(:) = {':'};
    
    combined_data = nan(size(window_data_cell{1}));
    
    for d = 1:length(combination_order)
        
        [combined_indices, window_indices] = deal(indices);
        
        combined_indices{dimension_combined} = d;
        
        window_indices{dimension_combined} = combination_order(d);

        combined_data(combined_indices{:}) = window_data_cell{d}(window_indices{:});
        
    end

end