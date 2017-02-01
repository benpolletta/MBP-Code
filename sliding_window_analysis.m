function [sw, window_time] = sliding_window_analysis(fcn_handle, data, sampling_freq, window_length, overlap, plot_opt, save_opt, filename, varargin)

[datalength, no_channels] = size(data);

if no_channels > datalength
    
    data = data';
    
    [datalength, no_channels] = size(data);
    
end

if isempty(window_length), window_length = sampling_freq; end

if isempty(overlap), overlap = round(window_length/2); end

time = (1:datalength)/sampling_freq;

no_windows = floor((datalength - window_length)/overlap);

window_time = nan(no_windows, 1);

first = feval(fcn_handle, data(1:window_length, 1), varargin{:});

sw = nan(length(first), no_windows, no_channels);

sw(:, 1, 1) = first;

window_time(1) = nanmean(time(1:window_length));

for ch = 1:no_channels
    
    for w = 2:no_windows
        
        window_start_index = (w - 1)*overlap + 1;
        
        window_end_index = (w - 1)*overlap + window_length;
        
        window_data = data(window_start_index:window_end_index, ch);
        
        window_time(w) = nanmean(time(window_start_index:window_end_index));
        
        sw(:, w, ch) = feval(fcn_handle, window_data, varargin{:});
        
    end
    
end

if save_opt
    
    save([filename, '.mat'], 'sw', 'window_time', 'window_length', 'overlap', 'sampling_freq')
    
end

if plot_opt
    
    no_x_ticks = 5;
    
    x_ticks = 1:floor(no_windows/no_x_ticks):no_windows;
    
    figure
    
    for ch = 1:no_channels
        
        subplot(2, no_channels, ch)
        
        imagesc(sw(:, :, ch))
        
        axis xy
        
        set(gca, 'XTick', x_ticks - .5, 'XTickLabel', round(window_time(x_ticks)))
        
        subplot(2, no_channels, no_channels + ch)
        
        imagesc(nanzscore(sw(:, :, ch)')')
        
        set(gca, 'XTick', x_ticks - .5, 'XTickLabel', round(window_time(x_ticks)))
        
    end
    
end