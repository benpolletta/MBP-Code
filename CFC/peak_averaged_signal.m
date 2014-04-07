function [Peak_segments,Peak_locs]=peak_averaged_signal(data,peak_freq,target_freq,no_target_cycles,sampling_freq,plot_opt,tit_le)

% Finds peaks in trace filtered at frequency peak_freq, spaced at least
% no_target_cycles cycles (at frequency target_freq) apart. Returns all
% segments in a matrix, and locations of peaks in a vector. If plot_opt=0, 
% no plots.If plot_opt=1, will plot peaks. If plot_opt=2, will plot peaks
% and also peak-triggered average.

data_length=length(data);
segment_length=floor(no_target_cycles*sampling_freq/target_freq);
if mod(segment_length,2) == 0
    segment_length=segment_length+1;
end
    
peak_freq_wavelet=dftfilt3(peak_freq, 7, sampling_freq, 'winsize', segment_length);

data_reflected=[flipud(data); data; flipud(data)];
peak_freq_filtered_reflected=conv(data_reflected,peak_freq_wavelet,'same');
peak_freq_filtered=peak_freq_filtered_reflected(data_length+1:2*data_length);
peak_freq_real=real(peak_freq_filtered);
peak_freq_mag=abs(peak_freq_filtered);
signal_length=length(peak_freq_filtered);

Maxima=nan(1,signal_length);
Max_locs=nan(1,signal_length);
Win_centers=nan(1,signal_length);

for i=1:signal_length

    win_center=i;
    win_start=max(1,win_center-floor(segment_length/2));
    win_end=min(signal_length,win_center+floor(segment_length/2));

    [maximum,location]=max(peak_freq_real(win_start:win_end));
    Maxima(i)=maximum;
    Max_locs(i)=location+win_start-1;
    Win_centers(i)=win_center;

end

% peak_freq_filtered=peak_freq_filtered(segment_length+1:end-segment_length);
% peak_freq_mag=peak_freq_mag(segment_length+1:end-segment_length);
% signal_length=length(peak_freq_mag);
% Maxima=Maxima(segment_length+1:end-segment_length);

if plot_opt>0

    figure(), plot(peak_freq_mag), hold on, plot(peak_freq_real,'k'), plot(Maxima,'c')

end
    
Peak_locs=Max_locs(Max_locs==Win_centers);

% Peak_locs=Peak_locs-segment_length;
Peak_locs=Peak_locs(Peak_locs>floor(segment_length/2) & Peak_locs<signal_length-floor(segment_length/2));

pfm_max=max(peak_freq_mag);
pfm_min=min(peak_freq_mag);

Peak_segments=nan(length(Peak_locs),segment_length);

for i=1:length(Peak_locs)
    
    peak_location=Peak_locs(i);
    
    if plot_opt>0
        
        plot([peak_location peak_location],[pfm_max pfm_min],'r')

    end
        
    segment_start=max(1,peak_location-floor(segment_length/2));
    segment_end=min(signal_length,peak_location+floor(segment_length/2));
    Peak_segments(i,:)=data(segment_start:segment_end)';
  
end

t=(1:segment_length)-floor(segment_length/2)-1;
t=t/sampling_freq;

if ~isempty(tit_le)
   
    save([tit_le,'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.mat'],'Peak_locs','Peak_segments','peak_freq','target_freq','sampling_freq');
    
end

if plot_opt>1
    
    figure()
    plot(t,mean(Peak_segments))
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal'])
    xlabel('Time From Peak (s)')
    
end