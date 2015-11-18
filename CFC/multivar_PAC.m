function kappa = multivar_PAC(data, sampling_freq, low_freq, hi_freqs, plot_opt)

[data_length, no_channels] = size(data);

no_freqs = length(hi_freqs) + 1;

Phases = nan(data_length, no_freqs, no_channels);

% Comb filtering at 60 Hz harmonics.

for f = 1:3
    
    notch_freq = 60*f;
    
    [n,Wn] = buttord(2*(notch_freq + 5*[-1 1])/sampling_freq, 2*(notch_freq + 2.5*[-1 1])/sampling_freq, 1, 20);
    
    [z, p, k] = butter(n,Wn,'stop'); [sos, g] = zp2sos(z, p, k); h = dfilt.df2sos(sos, g);
    
    data = filtfilthd(h, data, 'reflect');
    
end

for c = 1:no_channels
    
    [~, ~, ~, Phases(:, 1, c)] = filter_wavelet_Jan(data(:, c), 'sampling_freq', sampling_freq, 'bands', low_freq);
    
    [~, ~, A_hi, ~] = filter_wavelet_Jan(data(:, c), 'sampling_freq', sampling_freq, 'bands', hi_freqs);
    
    for f = 1:(no_freqs - 1)
        
        [~, ~, ~, Phases(:, f + 1, c)] = filter_wavelet_Jan(A_hi(:, f), 'sampling_freq', sampling_freq, 'bands', low_freq);
        
    end
    
end

Phases = reshape(Phases, data_length, no_freqs*no_channels);

kappa = fit_model(Phases');

if plot_opt
    
    load('/projectnb/crc-nak/brpp/Bernat_NMDAR_Antagonists/channels.mat')
    
    tick_labels = cell(no_freqs*no_channels, 1);
    
    for c = 1:no_channels
        
        tick_labels{(c - 1)*no_freqs + 1} = [display_channel_names{c}, ', ', num2str(low_freq), ' Hz'];
        
        for f = 1:(no_freqs - 1)
            
            tick_labels{(c - 1)*no_freqs + f + 1} = [display_channel_names{c}, ', ', num2str(hi_freqs(f)), ' Hz'];
            
        end
        
    end
    
    imagesc(abs(kappa))
    
    axis xy
    
    set(gca, 'XTick', 1:(no_freqs*no_channels), 'XTickLabel', tick_labels, 'YTick', 1:(no_freqs*no_channels), 'YTickLabel', tick_labels)
    
end