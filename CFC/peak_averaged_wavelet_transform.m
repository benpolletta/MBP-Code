function [t, freqs, Morlet, mean_peak_segment, no_peaks] = peak_averaged_wavelet_transform(data, peak_freq, peak_freq_cycles, sampling_freq, plot_opt, tit_le)

[Peak_segments, ~] = peak_averaged_signal(data, peak_freq, peak_freq, peak_freq_cycles, sampling_freq, 0, '');

[no_peaks, segment_length] = size(Peak_segments);

t = ((1:segment_length) - floor(segment_length/2))/sampling_freq;

freqs = 1:200;
no_freqs = length(freqs);

no_cycles = linspace(2,10,no_freqs);

wavelets = dftfilt3(freqs, no_cycles, sampling_freq, 'winsize', sampling_freq);

Morlet = zeros(no_freqs,segment_length);

for p = 1:no_peaks
   
    wt_temp = zeros(no_freqs,segment_length);
    
    segment = Peak_segments(p,:);
    
    segment_reflected = [fliplr(segment) segment fliplr(segment)];
    
    for f = 1:no_freqs
        
        conv_prod = conv(segment_reflected,wavelets(f,:),'same');
    
        wt_temp(f,:) = conv_prod(segment_length+1:2*segment_length);
        
    end
    
    Morlet = Morlet + abs(wt_temp);
    
end

Morlet = Morlet/no_peaks;

mean_peak_segment = mean(Peak_segments);

if ~isempty(tit_le)
   
    save([tit_le,'_',num2str(peak_freq),'_peak_wav.mat'],'Morlet','freqs','t','mean_peak_segment','no_peaks','peak_freq','sampling_freq');
    
end

if plot_opt > 0
    
    figure;
    
    subplot(2,1,1)
    imagesc(t,freqs,zscore(Morlet')')
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title([num2str(peak_freq),' Hz Peak-Triggered Wavelet Transform'])
%     set(gca,'YTick',freqs(1:floor(no_freqs/5):no_freqs))
    
    subplot(2,1,2)
    plot(t,mean_peak_segment)
    axis('tight'); box off;
    xlabel('Time (s)'); ylabel('mV');
    title([num2str(peak_freq),' Hz Peak-Triggered Mean Waveform'])
    
    save_as_pdf(gcf, [tit_le,'_',num2str(peak_freq),'_peak_wav'])
    
end