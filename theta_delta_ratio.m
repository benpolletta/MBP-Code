function [power_ratio, max_ratio] = theta_delta_ratio(data, sampling_freq, plot_opt)

freq_range = [0 5; 6 11];

colors = {'c', 'm'}; band_labels = {'\delta', '\theta'};

smooth_freq = .25;

if plot_opt, figure, end
    
if size(data, 1) ~= length(data), data = data'; end

for b = 1:2
    
    data = data(:, b);
    
    data = detrend(data);
    
    [data_hat, freqs] = pmtm(data, [], [], sampling_freq);
    
    if size(data_hat, 1) ~= length(data_hat), data_hat = data_hat'; end
    
    if size(freqs, 1) ~= length(freqs), freqs = freqs'; end
    
    flip_size = min(data_length, sampling_freq);
    
    data_hat_flipped = [flipud(data_hat(1:flip_size)); data_hat; flipud(data_hat((end - flip_size + 1):end))];
    
    gaussian_freqs = [-flipud(freqs(freqs < 5*smooth_freq)); freqs(freqs < 5*smooth_freq)];
    
    gaussian = normpdf(gaussian_freqs, 0, smooth_freq); gaussian = gaussian/sum(gaussian);
    
    data_hat_smoothed = conv(data_hat_flipped, gaussian, 'same');
    
    data_hat_smoothed = data_hat_smoothed((flip_size + 1):(end - flip_size));
    
    data_hat = [data_hat data_hat_smoothed];
    
    freq_indices = freqs >= freq_range(b, 1) & freqs <= freq_range(b, 2);
    
    for smoothed = 1:2
        
        data_hat_selected = data_hat(freq_indices, smoothed);
        
        power(b, smoothed) = sum(data_hat_selected);
        
        freqs_selected = freqs(freq_indices);
        
        [max_value(b, smoothed), max_index] = max(data_hat_selected);
        
        max_freq(b, smoothed) = freqs_selected(max_index);
        
        if plot_opt
            
            subplot(1, 2, b)
            
            plot(freqs_selected, data_hat_selected, colors{smoothed})
            
            hold on
            
            % plot(freqs_selected, power(b, smoothed)*ones(size(freqs_selected)), 'r-')
            
            plot(max_freq(b, smoothed), max_value(b, smoothed), 'rs')
            
            title(band_labels{b})
            
            xlabel('Freq. (Hz)')
            
            ylabel('Power')
            
            axis tight
            
        end
        
    end
    
end

power_ratio = power(2, :)./power(1, :);

max_ratio = max_value(2, :)./max_value(1, :);

if plot_opt
    
    subplot(1, 2, 1)
    
    legend({['Power = ', num2str(power_ratio(1), '%.3g'),...
        '; Max. = ', num2str(max_ratio(1), '%.3g')],...
        ['Smoothed Power = ', num2str(power_ratio(2), '%.3g'),...
        '; Smoothed Max. = ', num2str(max_ratio(2), '%.3g')]})
    
end