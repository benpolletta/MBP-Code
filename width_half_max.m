function [whm, shm_sum max_freq, max_value] = width_half_max(data, sampling_freq, freq_range, smooth_freq, plot_opt)

data_length = length(data);

if size(data, 1) ~= data_length, data = data'; end

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

freq_indices = freqs >= freq_range(1) & freqs <= freq_range(2);

data_hat_selected = data_hat_smoothed(freq_indices);

freqs_selected = freqs(freq_indices);

[max_value, max_index] = max(data_hat_selected);

max_freq = freqs_selected(max_index);

half_max = max_value/2;

super_hm_index = data_hat_selected >= half_max;

shm_sum = sum(super_hm_index);

super_hm_starts = find(diff([0; super_hm_index; 0]) == 1);

super_hm_ends = find(diff([0; super_hm_index; 0]) == -1);

whm_start = max(super_hm_starts(super_hm_starts < max_index));

whm_end = min(super_hm_ends(super_hm_ends > max_index)) - 1;

whm = whm_end - whm_start + 1;

if isempty(whm), whm = nan; end

if plot_opt == 1
    
    close('all')
   
    plot(freqs_selected, [data_hat(freq_indices) data_hat_selected])
    
    axis tight
    
    hold on
    
    plot(freqs_selected(whm_start:whm_end), half_max*ones(whm, 1), 'r-')
    
    plot(freqs_selected(max_index), max_value, 'rs')
    
end