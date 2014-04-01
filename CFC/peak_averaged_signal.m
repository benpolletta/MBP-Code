function [Peak_segments,Peak_locs]=peak_averaged_signal(data,peak_freq,target_freq,no_target_cycles,sampling_freq,plot_opt)

segment_length=no_target_cycles*floor(sampling_freq/target_freq)+1;
    
peak_freq_wavelet=dftfilt3(peak_freq, 8, sampling_freq, 'winsize', segment_length);
peak_freq_filtered=conv(data,peak_freq_wavelet);
%     peak_freq_filtered=peak_freq_filtered(sampling_freq/2+1:end-sampling_freq/2);
peak_freq_mag=abs(peak_freq_filtered);
signal_length=length(peak_freq_mag);

Maxima=nan(1,signal_length);
Max_locs=nan(1,signal_length);
Win_centers=nan(1,signal_length);

for i=1:signal_length

    win_center=i;
    win_start=max(1,win_center-floor(segment_length/2));
    win_end=min(signal_length,win_center+floor(segment_length/2));

    [maximum,location]=max(peak_freq_mag(win_start:win_end));
    Maxima(i)=maximum;
    Max_locs(i)=location+win_start-1;
    Win_centers(i)=win_center;

end

peak_freq_filtered=peak_freq_filtered(segment_length+1:end-segment_length);
peak_freq_mag=peak_freq_mag(segment_length+1:end-segment_length);
signal_length=length(peak_freq_mag);
Maxima=Maxima(segment_length+1:end-segment_length);

if plot_opt==1

    figure(), plot(peak_freq_mag), hold on, plot(real(peak_freq_filtered),'k'), plot(Maxima,'c')

end
    
Peak_locs=Max_locs(Max_locs==Win_centers);

Peak_locs=Peak_locs-segment_length;
Peak_locs=Peak_locs(Peak_locs>floor(segment_length/2) & Peak_locs<signal_length-floor(segment_length/2));

pfm_max=max(peak_freq_mag);
pfm_min=min(peak_freq_mag);

Peak_segments=nan(length(Peak_locs),segment_length);

for i=1:length(Peak_locs)
    
    peak_location=Peak_locs(i);
    
    if plot_opt==1
        
        plot([peak_location peak_location],[pfm_max pfm_min],'r')

    end
        
    segment_start=max(1,peak_location-floor(segment_length/2));
    segment_end=min(signal_length,peak_location+floor(segment_length/2));
    Peak_segments(i,:)=data(segment_start:segment_end)';
  
end

t=(1:segment_length)-floor(segment_length/2)-1;
t=t/sampling_freq;

if plot_opt==1
    
    figure()
    plot(t,mean(Peak_segments))
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal'])
    xlabel('Time From Peak (s)')
    
end