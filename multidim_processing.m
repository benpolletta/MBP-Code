function data_processed = multidim_processing(process_handle, data,...
    dims_consumed, dims_not_consumed, size_produced, output_shape, filename, varargin)

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
    
    save([filename, '.mat'], 'data_procesed', 'size_produced', 'dim_indices', 'process_handle', 'varargin')

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