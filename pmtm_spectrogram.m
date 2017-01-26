function [ps, freqs, window_time] = pmtm_spectrogram(data, sampling_freq, thbw, window_length, overlap, plot_opt, save_opt, filename)

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

[first, freqs] = pmtm(data(1:window_length), thbw, [], sampling_freq);

ps = nan(length(freqs), no_windows);

ps(:, 1) = first;

parfor w = 2:no_windows
    
    window_start_index = (w - 1)*overlap + 1;
    
    window_end_index = (w - 1)*overlap + window_length;
    
    window_data = data(window_start_index:window_end_index);
    
    window_time(w) = nanmean(time(window_start_index:window_end_index));
    
    ps(:, w) = pmtm(window_data, thbw, [], sampling_freq);
    
end

if save_opt
    
    save([filename, '.mat'], 'ps', 'freqs', 'window_time', 'window_length', 'overlap', 'thbw', 'sampling_freq')
    
end

if plot_opt
    
    figure
    
    subplot(211)
    
    imagesc(ps)
    
    hold on
    
    plot(window_time, nanzscore(ps(find(min(abs(freqs - 20))), :)'), 'w')
    
    axis xy
    
    ylabel('Freq. (Hz)')
    
    subplot(212)
    
    imagesc(nanzscore(ps')')
    
    axis xy
   
    xlabel('Time (s)')
    
    ylabel('Freq. (Hz)')
    
end
