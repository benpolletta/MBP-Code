function comparison_struct = init_comparisons(SW_size, dimension_compared, indices_compared,...
    dimensions_ranged_over, comparison_ranges, dimensions_truncated, dimension_subsets, comparison_name)

number_dimensions = length(SW_size);

for d = 1:number_dimensions
    
    left_index{d} = ':';
    
    right_index{d} = ':';
    
end

left_index{dimension_compared} = indices_compared(1);

right_index{dimension_compared} = indices_compared(2);

for d = 1:length(dimensions_truncated)
    
    left_index{dimensions_truncated(d)} = dimension_subsets{d};
    
    right_index{dimensions_truncated(d)} = dimension_subsets{d};
    
end

if size(dimensions_ranged_over, 1) > size(dimensions_ranged_over, 2)
    
    dimensions_ranged_over = dimensions_ranged_over';

end
    
[dimensions_ranged_over, dimensions_ranged_over_order] = sort(dimensions_ranged_over, 2, 'descend');

comparison_ranges = comparison_ranges(dimensions_ranged_over_order);

comparison_size = fliplr(cell2mat(cellfun(@(x) length(x), comparison_ranges, 'UniformOutput', 0)));

total_comparisons = prod(comparison_size);

comparison_indices = cell(total_comparisons, 2);

indices_ranged_over = setprod(comparison_ranges{:});

indices_ranged_over = mat2cell(indices_ranged_over, ones(total_comparisons, 1), ones(length(comparison_ranges), 1));

for c = 1:total_comparisons
   
    left_comparison_index = left_index;
    
    left_comparison_index(dimensions_ranged_over) = indices_ranged_over(c, :);
    
    comparison_indices{c, 1} = left_comparison_index;
    
    right_comparison_index = right_index;
    
    right_comparison_index(dimensions_ranged_over) = indices_ranged_over(c, :);
    
    comparison_indices{c, 2} = right_comparison_index;
    
end

comparison_struct = init_struct({'comparison_name', 'comparison_size', 'comparison_indices'},...
    {comparison_name, comparison_size, comparison_indices});
