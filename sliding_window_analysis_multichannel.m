function [sw, window_time] = sliding_window_analysis_multichannel(fcn_handle, data, sampling_freq, sliding_window_cell, save_opt, filename, varargin)

% Performs sliding window analysis of given data using supplied function handle.
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

%% Initializing output array, indices required to index into this multidimensional array.

data_size = size(data);

data_dimensions = length(data_size);

sliding_window_cell = check_args(sliding_window_cell, data_size);

[time, window_time, first_indices] = deal(cell(data_dimensions, 1));

% Find number of windows in each dimension.

no_windows = nan(data_dimensions, 1);

for d = 1:data_dimensions

    time{d} = (1:data_size(d))/sampling_freq{d};

    no_windows(d) = ceil((data_size(d) - sliding_window_cell{d}(1) + 1)/sliding_window_cell{d}(2));

    window_time{d} = nan(no_windows(d), 1);
    
end

% Linearize looping over all combinations of window numbers (over all dimensions).

total_windows = prod(no_windows);

[window_numbers{1:data_dimensions}] = ind2sub(no_windows, 1:total_windows);

% Find indices and times of first window (i.e., window numbers (1,1,...,1)).

for d = 1:data_dimensions

    first_indices{d} = 1:sliding_window_cell{d}(1);
    
    window_time{d}(1) = nanmean(time{d}(first_indices{d}));
    
end

% Find size of output based on output from first window.

first = feval(fcn_handle, data(first_indices{:}), varargin{:});

output_size = size(first);

% Find size of array needed to hold outputs from all windows, based on size
% of output from a single window and on the number of windows in each
% dimension.

sw_size = [output_size, total_windows];

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

sw(sw_indices{:}) = first; % Assign first window in sw to output from first window.

%% Analysis by window.

for w = 2:total_windows
    
    % For each data dimension, assigning number of window (in given
    % dimension), indices into data for that window, and center time of
    % that window.
    
    for d = 1:data_dimensions
    
        w_dim = window_numbers{d}(w); % Number of window (in dimension d).
        
        window_d = sliding_window_cell{d}(1); % Window size in this dimension.
        
        step_d = sliding_window_cell{d}(2); % Step size in this dimension.
        
        window_start_index = (w_dim - 1)*step_d + 1; % Start of window in this dimension.
        
        window_end_index = (w_dim - 1)*step_d + window_d; % End of window in this dimension.
        
        window_indices{d} = window_start_index:window_end_index; % Indices of window in this dimension.
    
        window_time{d}(w_dim) = nanmean(time{d}(window_start_index:window_end_index)); % Center time of window in this dimension.
        
    end
    
    window_data = data(window_indices{:}); % Getting data for this window.
    
    sw_indices{end} = w; % Setting up indices into output array for this window.
    
    sw(sw_indices{:}) = feval(fcn_handle, window_data, varargin{:}); % Assigning output to output array.
    
end

sw = squeeze(reshape(sw, [output_size, no_windows'])); % Reshaping output array from linear over windows to multidimensional over each window dimension.

if save_opt
    
    window_time_cell = cellfun(@(x,y) x/y, sliding_window_cell, sampling_freq, 'UniformOutput', 0);
    
    analysis_name = make_sliding_window_analysis_name(filename, func2str(fcn_handle), window_time_cell, length(size(data)), varargin{:});
    
    % varargin_name = make_varargin_name(varargin{:});
    
    save([analysis_name, '.mat'], 'sw', 'window_time', 'sliding_window_cell', 'sampling_freq', 'output_size', 'no_windows')
    
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