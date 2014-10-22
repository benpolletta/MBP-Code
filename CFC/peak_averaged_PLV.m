function [t, freqs, mean_PLV, mean_peak_segments, no_peaks] = peak_averaged_PLV(data1, data2, peak_freq, peak_freq_cycles, sampling_freq, plot_opt, tit_le)

[Peak_segments, Peak_locs] = peak_averaged_signal(data1, peak_freq, peak_freq, peak_freq_cycles, sampling_freq, 0, '');

Peak_segments(:, :, 2) = apply_peak_locs(data2, Peak_locs, peak_freq, peak_freq, peak_freq_cycles, sampling_freq, '');

[no_peaks, segment_length, ~] = size(Peak_segments);

t = ((1:segment_length) - floor(segment_length/2))/sampling_freq;

freqs = 1:200;
no_freqs = length(freqs);

no_cycles = 7*ones(1, no_freqs);

wavelets = dftfilt3(freqs, no_cycles, sampling_freq, 'winsize', sampling_freq);

%[mean_wt_pow, mean_wt_phase] = deal(zeros(no_freqs, segment_length, 2));

mean_PLV = zeros(no_freqs, segment_length);

for p = 1:no_peaks
   
    wt_temp = zeros(no_freqs, segment_length, 2);
    
    for ch = 1:2
        
        segment = Peak_segments(p, :, ch);
        
        segment_reflected = [fliplr(segment) segment fliplr(segment)];
        
        for f = 1:no_freqs
            
            conv_prod = conv(segment_reflected,wavelets(f,:),'same');
            
            wt_temp(f, :, ch) = conv_prod(segment_length+1:2*segment_length);
            
        end
        
    end
    
    % mean_wt_pow = mean_wt_pow + abs(wt_temp)/no_peaks;
    % 
    % mean_wt_phase = mean_wt_phase + exp(sqrt(-1)*angle(wt_temp))/no_peaks;
    
    Phase_diff = -diff(angle(wt_temp), [], 3);
    
    PLV = nan(size(Phase_diff));
    
    for f = 1:no_freqs
        
        smooth_size = 5*round(no_cycles(f)*1000/freqs(f));
       
        PLV(f, :) = abs(conv(exp(sqrt(-1)*Phase_diff(f, :)), hann(smooth_size), 'same')/sum(hann(smooth_size)));
        
    end
    
    mean_PLV = mean_PLV + PLV/no_peaks;
    
end

mean_peak_segments = reshape(mean(Peak_segments), [size(Peak_segments, 2) size(Peak_segments, 3)]);

if ~isempty(tit_le)

    save([tit_le,'_',num2str(peak_freq),'_peak_PLV.mat'],'mean_PLV','freqs','t','mean_peak_segments','no_peaks','peak_freq','sampling_freq');
    
end

if plot_opt > 0
    
    figure;
    
    subplot(2,1,1)
    imagesc(t, freqs, mean_PLV)
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title([num2str(peak_freq),' Hz Peak-Triggered Phase-Locking Value (Mean)'])
    % set(gca,'YTick',freqs(1:floor(no_freqs/5):no_freqs))
    
    subplot(2,1,2)
    plot(t', mean_peak_segments)
    axis('tight'); box off;
    xlabel('Time (s)'); ylabel('mV');
    title([num2str(peak_freq),' Hz Peak-Triggered Mean Waveform'])
    
    save_as_pdf(gcf, [tit_le,'_',num2str(peak_freq),'_peak_wav'])
    
end