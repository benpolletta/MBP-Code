function data_processed = multidim_processing(process_handle, data,...
    dims_consumed, dims_not_consumed, size_produced, output_shape, filename, varargin)

% Performs analysis of specified dimensions of a multidimensional array,
% by iterating over remaining dimensions.
% Returns either: 
% (1) a multidimensional array, whose first n dimensions contain the
%  (n-dimensional) output from each application of process_handle to a
%  combination of non-processed dimensions, and whose remaining dimensions
%  are in the same order as data;
% (2) an n+1 dimensional array, whose first n-dimensions contain the
%  (n-dimensional) output from each appliction of process_handle to a
%  combination of non-processed dimensions, and whose remaining dimension
%  contains all combinations of non-processed dimensions in column major
%  order.
% * process_handle - the function to be performed on data(dims_consumed).
% * data - the multidimensional array containing the data supplied to the function.
% * dims_consumed - indices of which dimensions of data are supplied to process_handle.
% * dims_not_consumed - indices of which dimensions of data are left
%   intact.
% * size_produced - the size of the output from each application of
%   process_handle to data(dims_consumed).
% * output_shape - whether to maintain dimensions dims_not_consumed as
%   multidimensional in the same order as in data ('same'), or to linearize
%   these dimensions ('linear').
% * filename - name to save the output files to.
% * varargin - extra variables to be passed to the function process_handle.

data = permute(data, [dims_consumed, dims_not_consumed]);

data_size = size(data);

no_iterations = prod(data_size(dims_not_consumed));

data_for_process = reshape(data, [data_size(dims_consumed), no_iterations]);

data_processed = nan([size_produced, no_iterations]); 

for d = 1:length(dims_consumed)
    
    data_indices{d} = {':'};
    
end

for d = 1:length(size_produced)
   
    output_indices{d} = {':'};
    
end

for p = 1:no_iterations
    
    data_processed(output_indices{:}, p) = feval(process_handle, data_for_process(data_indices{:}, p), varargin{:});
    
end

if strcmp(output_shape, 'same')

    data_processed = reshape(data_processed, [size_produced, data_size(dims_not_consumed)]);
    
    dim_indices = data_size(dims_not_consumed);
    
elseif strcmp(output_shape, 'linear')
    
    dim_indices = linear_dimension_indices(data_size(dims_not_consumed));
    
end

if ~isempty(filename)
    
    save([filename, '_', func2str(function_handle), '.mat'], 'data_procesed', 'size_produced', 'dim_indices', 'process_handle', 'varargin')

end

end

function dim_indices = linear_dimension_indices(size_vec)

no_dimensions = length(size_vec);

dim_indices = nan([size_vec, no_dimensions]);

[index_location_cell, index_size_cell] = deal(cell(no_dimensions, 1));

for d = 1:no_dimensions
    
    index_location_cell{d} = ':';
    
end

for dim = 1:no_dimensions
    
    dim_size = size_vec(dim);
    
    for d = 1:no_dimensions
    
        index_size_cell{d} = '1';
    
    end
    
    index_size_cell{dim} = dim_size;
    
    dim_indices(index_location_cell{:}, dim) = cumsum(ones(index_size_cell{:}), dim); 
    
end

dim_indices = reshape(dim_indices, prod(size_vec), no_dimensions);

end