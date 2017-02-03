function [sw, window_time] = sliding_window_analysis_multichannel(fcn_handle, data, sampling_freq, window_length, step, plot_opt, save_opt, filename, varargin)

% Performs sliding window analysis of data given a function.

analysis_flag = sprintf('_%s_window%g_step%g', fcn_handle(2:end), window_length/sampling_freq, step/sampling_freq);

[datalength, no_channels] = size(data);

if no_channels > datalength
    
    data = data';
    
    [datalength, no_channels] = size(data);
    
end

if isempty(window_length), window_length = sampling_freq; end

if isempty(step), step = round(window_length/2); end

time = (1:datalength)/sampling_freq;

no_windows = floor((datalength - window_length)/step);

window_time = nan(no_windows, 1);

first = feval(fcn_handle, data(1:window_length, :), varargin{:});

output_size = size(first);

sw_size = [output_size, no_windows];

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

window_time(1) = nanmean(time(1:window_length));

for w = 1:no_windows
    
    window_start_index = (w - 1)*step + 1;
    
    window_end_index = (w - 1)*step + window_length;
    
    window_data = data(window_start_index:window_end_index, :);
    
    window_time(w) = nanmean(time(window_start_index:window_end_index));
    
    sw_indices{end} = w;
    
    sw(sw_indices{:}) = feval(fcn_handle, window_data, varargin{:});
    
end

if save_opt
    
    save([filename, analysis_flag, '.mat'], 'sw', 'window_time', 'window_length', 'step', 'sampling_freq')
    
end

if plot_opt
    
    no_x_ticks = 5;
    
    x_ticks = 1:floor(no_windows/no_x_ticks):no_windows;
    
    no_plots = prod(sw_size(2:(end - 1)));
    
    sw_plot = reshape(sw, sw_size(1), no_plots, no_windows);
    
    sw_plot = permute(sw_plot, [1 3 2]);
    
    [figure_indices, subplot_indices, no_rows, no_cols] = linear_figure_indices(sw_size(2:(end - 1)), [], []);
    
    for p = 1:no_plots
        
        figure(figure_indices(p))
        
        subplot(no_rows, no_cols, subplot_indices(p))
        
        imagesc(abs(sw_plot(:, :, p)))
        
        axis xy
        
        set(gca, 'XTick', x_ticks - .5, 'XTickLabel', round(window_time(x_ticks)))
        
        figure(max(figure_indices) + figure_indices(p))
        
        subplot(no_rows, no_cols, subplot_indices(p))
        
        imagesc(nanzscore(abs(sw_plot(:, :, p)')'))
        
        axis xy
        
        set(gca, 'XTick', x_ticks - .5, 'XTickLabel', round(window_time(x_ticks)))
        
    end
    
    for f = 1:max(figure_indices)
        
        save_as_pdf(f, [filename, analysis_flag '_', num2str(f)])
        
        save_as_pdf(max(figure_indices) + f, [filename, analysis_flag, '_', num2str(f)])
        
    end
    
end

end


function [fig_indices, subplot_indices, no_rows, no_cols] = linear_figure_indices(size, max_row_index, max_col_index)

if isempty(max_row_index), max_row_index = 10; end

if isempty(max_col_index), max_col_index = 10; end

if length(size) > 1
    
    if size(1) <= max_row_index && size(2) <= max_col_index
        
        no_rows = size(1);
        
        no_cols = size(2);
        
        fig_start_index = 3;
        
    elseif size(1) <= max_row_index*max_col_index
        
        [no_rows, no_cols] = subplot_size(size(1));
        
        fig_start_index = 2;
        
    else
        
        no_rows = max_row_index;
        
        no_cols = max_col_index;
        
        size(1) = ceil(size(1)/(max_row_index*max_col_index));
        
        fig_start_index = 1;
        
    end
    
elseif size(1) <= max_row_index*max_col_index
    
    [no_rows, no_cols] = subplot_size(size(1));
    
    fig_start_index = 2;
    
else
    
    no_rows = max_row_index;
    
    no_cols = max_col_index;
    
    size(1) = ceil(size(1)/(max_row_index*max_col_index));
    
    fig_start_index = 1;
    
end

% fig_start_index = min(fig_start_index, length(size));

no_figures = prod(size(fig_start_index:end));

figure_subplot_indices = linear_subplot_indices(no_rows, no_cols);

subplot_indices = repmat(figure_subplot_indices, 1, no_figures);

subplot_indices = reshape(subplot_indices, no_rows*no_cols*no_figures, 1);

fig_indices = cumsum(ones(no_rows*no_cols, no_figures), 2);

fig_indices = reshape(fig_indices, no_rows*no_cols*no_figures, 1);

end


function subplot_indices = linear_subplot_indices(no_rows, no_cols)

subplot_indices = reshape(1:(no_rows*no_cols), no_cols, no_rows)';

subplot_indices = reshape(subplot_indices, no_rows*no_cols, 1);

end