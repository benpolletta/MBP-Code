function [sw, window_time] = sliding_window_analysis_multichannel(fcn_handle, data, sampling_freq, sliding_window_cell, plot_opt, save_opt, filename, varargin)

% Performs sliding window analysis of given data using supplied function handle.
% * fcn_handle - the function to be performed on each window.
% * data - the data given to the function (can be a vector or a matrix or an array).
% * sampling_freq - (cell array) the sampling frequency of eachdimension of data.
% * sliding_window_cell - a cell array whose length matches the number of
%   dimensions of the input data. The nth cell contains a 2-vector
%   (window_length, step_length), which gives the length of the windows (and
%   the steps by which these windows are offset) for the sliding window
%   analysis in dimension n.
% * step - the length (in data indices) that each window is offset relative
%   to the previous one. Default is sampling_freq/2.
% * plot_opt - plot the output (1) or not (0).
% * save_opt - save the output (1) or not (0).
% * filename - name to save the output files to; if empty, uses a flag
%   containing the function and the window length and step length.
% * varargin - extra variables to be passed to the function.

data_size = size(data);

data_dimensions = length(data_size);

sliding_window_cell = check_args(sliding_window_cell, data_size);

[time, window_time, first_indices] = deal(cell(data_dimensions, 1));

no_windows = nan(data_dimensions, 1);

for d = 1:data_dimensions

    time{d} = (1:data_size(d))/sampling_freq{d};

    no_windows(d) = ceil((data_size(d) - sliding_window_cell{d}(1) + 1)/sliding_window_cell{d}(2));

    window_time{d} = nan(no_windows(d), 1);
    
end

total_windows = prod(no_windows);

[window_numbers{1:data_dimensions}] = ind2sub(no_windows, 1:total_windows);

for d = 1:data_dimensions

    first_indices{d} = 1:sliding_window_cell{d}(1);
    
    window_time{d}(1) = nanmean(time{d}(first_indices{d}));
    
end

first = feval(fcn_handle, data(first_indices{:}), varargin{:});

output_size = size(first);

sw_size = [output_size, total_windows];

output_dim = length(output_size);

sw_dim = output_dim + 1;

[sw_size_cell, sw_indices] = deal(cell(sw_dim, 1));

for d = 1:sw_dim
    
    sw_size_cell{d} = sw_size(d);
    
    sw_indices{d} = ':';
    
end

sw = nan(sw_size_cell{:});

sw_indices{end} = 1;

sw(sw_indices{:}) = first;

for w = 2:total_windows
    
    for d = 1:data_dimensions
    
        w_dim = window_numbers{d}(w);
        
        window_dim = sliding_window_cell{d}(1);
        
        step_dim = sliding_window_cell{d}(2);
        
        window_start_index = (w_dim - 1)*step_dim + 1;
        
        window_end_index = (w_dim - 1)*step_dim + window_dim;
        
        window_indices{d} = window_start_index:window_end_index;
    
        window_time{d}(w_dim) = nanmean(time{d}(window_start_index:window_end_index));
        
    end
    
    window_data = data(window_indices{:});
    
    sw_indices{end} = w;
    
    sw(sw_indices{:}) = feval(fcn_handle, window_data, varargin{:});
    
end

sw = squeeze(reshape(sw, [output_size, no_windows']));

if save_opt
    
    window_time_cell = cellfun(@(x,y) x/y, sliding_window_cell, sampling_freq, 'UniformOutput', 0);
    
    analysis_name = make_sliding_window_analysis_name(filename, func2str(fcn_handle), window_time_cell, length(size(data)));
    
    save([analysis_name, '.mat'], 'sw', 'window_time', 'sliding_window_cell', 'sampling_freq', 'output_size', 'no_windows')
    
end

if plot_opt
    
    % Plotting goes here.
    
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