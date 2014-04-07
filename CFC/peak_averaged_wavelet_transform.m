function [t, freqs, Morlet, mean_peak_segment] = peak_averaged_wavelet_transform(data, peak_freq, sampling_freq, plot_opt, tit_le)

[Peak_segments, ~] = peak_averaged_signal(data, peak_freq, peak_freq, 1.5, sampling_freq, 0, '');

[no_peaks, segment_length] = size(Peak_segments);

t = ((1:segment_length) - floor(segment_length/2))/sampling_freq;

MorletFourierFactor = 4*pi/(6+sqrt(2+6^2));
freqs = 1:200;
scales = 1./(freqs*MorletFourierFactor);
no_scales = length(scales);

Morlet = zeros(no_scales,segment_length);

for p = 1:no_peaks
   
    sig =  struct('val',Peak_segments(p,:),'period',sampling_freq);
    cwt = cwtft(sig,'scales',1./[1:1:200]);
    
    Morlet = Morlet + abs(cwt.cfs);
    
end

Morlet = Morlet/no_peaks;

mean_peak_segment = mean(Peak_segments);

if ~isempty(tit_le)
   
    save([tit_le,'_',num2str(peak_freq),'_peak_wav.mat'],'Morlet','freqs','t','mean_peak_segment','peak_freq','sampling_freq');
    
end

if plot_opt > 0
    
    figure;
    
    subplot(2,1,1)
    imagesc(t,freqs,zscore(Morlet')')
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Pseudo-frequency (Hz)');
    title([num2str(peak_freq),' Hz Peak-Triggered Wavelet Transform'])
    set(gca,'YTick',freqs)
    
    subplot(2,1,2)
    plot(t,mean_peak_segment)
    xlabel('Time (s)'); ylabel('mV');
    title([num2str(peak_freq),' Hz Peak-Triggered Mean Waveform'])
    
    save_as_pdf(gcf, [tit_le,'_',num2str(peak_freq),'_peak_wav'])
    
end