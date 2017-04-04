function [sw, window_time] = sliding_window_shuffle_multichannel(fcn_handle, data, sampling_freq, sliding_window_cell, shuffle_struct, save_opt, filename, varargin)

% Creates window-shuffled surrogate data for the corresponding sliding
% window analysis of given data using supplied function handle.
% * fcn_handle - the function to be performed on each window.
% * data - the data given to the function (can be a vector or a matrix or an array).
% * sampling_freq - (cell array) the sampling frequency of eachdimension of data.
% * sliding_window_cell - a cell array whose length matches the number of
%   dimensions of the input data. The nth cell contains a 2-vector
%   (window_length, step_length), which gives (in indices) the length of
%   the windows (and the lengths of the steps by which these windows are
%   offset) for the sliding window analysis in dimension n.
% * step - the length (in data indices) that each window is offset relative
%   to the previous one. Default is sampling_freq/2.
% * plot_opt - plot the output (1) or not (0).
% * save_opt - save the output (1) or not (0).
% * filename - name to save the output files to; if empty, uses a flag
%   containing the function and the window length and step length.
% * varargin - extra variables to be passed to the function.

%% Initializing structure containing shuffle parameters.

if isempty(shuffle_struct)
    
    shuffle_struct = init_struct({'shuffle_struct.shuffle_dims', 'no_shuffles', 'combine_pairs', 'varargin'},...
        {1, 1000, @combine_dimension, {2, [1 2]}});
    
end

%% Initializing combinations of window numbers for shuffles.

data_size = size(data);

data_dimensions = length(data_size);

sliding_window_cell = check_args(sliding_window_cell, data_size);

[time, window_time] = deal(cell(data_dimensions, 1));

% Find number of windows in each dimension.

no_windows = nan(data_dimensions, 1);

for d = 1:data_dimensions

    time{d} = (1:data_size(d))/sampling_freq{d};

    no_windows(d) = ceil((data_size(d) - sliding_window_cell{d}(1) + 1)/sliding_window_cell{d}(2));
    
end

% Linearize looping over all combinations of shuffled window numbers (over all shuffled dimensions). % shuffle_dimensionality = length(shuffle_struct.shuffle_dims);

total_shuffle_windows = prod(no_windows(shuffle_struct.shuffle_dims));

[shuffle_window_numbers{1:data_dimensions}] = ind2sub(no_windows(shuffle_struct.shuffle_dims), (1:total_shuffle_windows)');

shuffle_window_numbers = cell2mat(shuffle_window_numbers);

singleton_columns = sum(shuffle_window_numbers > 1) == 0;

shuffle_window_numbers(:, singleton_columns) = []; 

% Getting shuffles.

[windowA, windowB] = random_pairs(shuffle_struct.no_shuffles, total_shuffle_windows);

shuffles = [windowA windowB];

no_shuffles = size(shuffles, 1);

% Linearize looping over all combinations of unshuffled window numbers (over all unshuffled dimensions).

slide_dims = find(~blocks_to_index(repmat(shuffle_struct.shuffle_dims', 1, 2), 1:data_dimensions)); % slide_dimensionality = length(slide_dims);

total_slide_windows = prod(no_windows(slide_dims));

[slide_window_numbers{1:data_dimensions}] = ind2sub(no_windows(slide_dims), (1:total_slide_windows)');

slide_window_numbers = cell2mat(slide_window_numbers);

singleton_columns = sum(slide_window_numbers > 1) == 0;

slide_window_numbers(:, singleton_columns) = [];

% Combining window_numbers for shuffled and slid dimensions.

total_shuffles = no_shuffles*total_slide_windows;

window_numbers = nan(total_shuffles, data_dimensions, 2);

for s = 1:total_slide_windows
    
    window_numbers((s - 1)*no_shuffles + (1:no_shuffles), slide_dims, :) = slide_window_numbers(s, :);
    
    for pair_element = 1:2
    
        window_numbers((s - 1)*no_shuffles + (1:no_shuffles), shuffle_struct.shuffle_dims, pair_element)...
            = shuffle_window_numbers(shuffles(:, pair_element), :);
        
    end
    
end

shuffle_time = nan(total_shuffles, data_dimensions, 2);

%% Find size of output based on output from first window (i.e., window numbers (1,1,...,1)).

for s = 1

    shuffle_indices = cell(data_dimensions, 2);
    
    for pair_element = 1:2
        
        for d = 1:data_dimensions
            
            window_value_d = window_numbers(s, d); % Number of window (in dimension d).
            
            window_d = sliding_window_cell{d}(1); % Window size in this dimension.
            
            step_d = sliding_window_cell{d}(2); % Step size in this dimension.
            
            window_start_index = (window_value_d - 1)*step_d + 1; % Start of window in this dimension.
            
            window_end_index = (window_value_d - 1)*step_d + window_d; % End of window in this dimension.
            
            shuffle_indices{d, pair_element} = window_start_index:window_end_index; % Indices of window in this dimension.
            
            shuffle_time(s, d, pair_element) = nanmean(time{d}(window_start_index:window_end_index)); % Center time of window in this dimension.
            
        end
        
    end
    
end

first_shuffle_data = feval(shuffle_struct.combine_pairs, {data(shuffle_indices{:, 1}),...
        data(shuffle_indices{:, 2})}, shuffle_struct.varargin{:});

first = feval(fcn_handle, first_shuffle_data, varargin{:});

output_size = size(first);

% Find size of array needed to hold outputs from all windows, based on size
% of output from a single window and on the number of windows in each
% dimension.

sw_size = [output_size, no_shuffles];

output_dim = length(output_size);

sw_dim = output_dim + 1;

% Initialize cell holding indices for each window, and size arguments for
% array to hold outputs from all windows.

[sw_size_cell, sw_indices] = deal(cell(sw_dim, 1));

for d = 1:sw_dim
    
    sw_size_cell{d} = sw_size(d);
    
    sw_indices{d} = ':';
    
end

sw = nan(sw_size_cell{:}); % Initialize array to hold outputs from all windows.

sw_indices{end} = 1; % Set up indices of first window in array sw.

%% Analysis of shuffles.

for s = 1:total_shuffles
    
    % For each data dimension, assigning number of window (in given
    % dimension), indices into data for that window, and center time of
    % that window.

    shuffle_indices = cell(data_dimensions, 2);
    
    for pair_element = 1:2
        
        for d = 1:data_dimensions
            
            window_value_d = window_numbers(s, d, pair_element); % Number of window (in dimension d).
            
            window_d = sliding_window_cell{d}(1); % Window size in this dimension.
            
            step_d = sliding_window_cell{d}(2); % Step size in this dimension.
            
            window_start_index = (window_value_d - 1)*step_d + 1; % Start of window in this dimension.
            
            window_end_index = (window_value_d - 1)*step_d + window_d; % End of window in this dimension.
            
            shuffle_indices{d, pair_element} = window_start_index:window_end_index; % Indices of window in this dimension.
            
            shuffle_time(s, d, pair_element) = nanmean(time{d}(window_start_index:window_end_index)); % Center time of window in this dimension.
            
        end
        
    end
    
    shuffle_data = feval(shuffle_struct.combine_pairs, {data(shuffle_indices{:, 1}),...
        data(shuffle_indices{:, 2})}, shuffle_struct.varargin{:}); % Getting data for this shuffle.
    
    sw_indices{end} = s; % Setting up indices into output array for this window.
    
    sw(sw_indices{:}) = feval(fcn_handle, shuffle_data, varargin{:}); % Assigning output to output array.
    
end

no_windows = [no_shuffles, no_windows(slide_dims)];

sw = squeeze(reshape(sw, [output_size, no_windows])); % Reshaping output array from linear over windows to multidimensional over each window dimension.

if save_opt
    
    window_time_cell = cellfun(@(x,y) x/y, sliding_window_cell, sampling_freq, 'UniformOutput', 0);
    
    analysis_name = make_sliding_window_analysis_name(filename, func2str(fcn_handle), window_time_cell, length(size(data)), varargin{:});
    
    if isempty(regexp(analysis_name, 'shuffle', 'once'))
    
        save([analysis_name, '_shuffles.mat'], 'sw', 'shuffle_time', 'sliding_window_cell', 'sampling_freq', 'output_size', 'no_windows', 'shuffles', 'shuffle_time')
        
    else
    
        save([analysis_name, '.mat'], 'sw', 'shuffle_time', 'sliding_window_cell', 'sampling_freq', 'output_size', 'no_windows', 'shuffles', 'shuffle_time')
        
    end
    
end

end

function sliding_window_cell = check_args(sliding_window_cell, data_size)

data_dimensions = length(data_size);

if length(sliding_window_cell) > data_dimensions
    
    display(sprintf(['Fourth argument to sliding_window_analysis_multichannel is a cell array\n',...
        'whose length matches the number of dimensions of the input data.\n',...
        'The nth cell contains a 2-vector (window_length, step_length), which gives\n',...
        'the length of the windows (and the steps by which these windows are offset)\n',...
        'for the sliding window analysis in dimension n.']))

end
    
% Filling out the rest of the windows if only a first few are specified.
for d = (length(sliding_window_cell) + 1):data_dimensions
    
    sliding_window_cell{d} = data_size(d)*ones(1, 2);
    
end

% Filling out the rest of the windows if they are left empty.
for d = 1:data_dimensions
    
    if isempty(sliding_window_cell{d})
        
        sliding_window_cell{d} = data_size(d)*ones(1, 2);
        
    end
    
end

% [datalength, no_channels] = size(data);
% 
% if no_channels > datalength
%     
%     data = data';
%     
%     [datalength, no_channels] = size(data);
%     
% end

% if isempty(window_lengths), window_lengths = sampling_freq; end
% 
% if isempty(steps), steps = round(window_lengths/2); end

end