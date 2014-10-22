function Peak_segments = apply_peak_locs(data, Peak_locs, peak_freq, target_freq, no_target_cycles, sampling_freq, filename)

% Finds peaks in trace filtered at frequency peak_freq, spaced at least
% no_target_cycles cycles (at frequency target_freq) apart. Returns all
% segments in a matrix, and locations of peaks in a vector. If plot_opt=0, 
% no plots.If plot_opt=1, will plot peaks. If plot_opt=2, will plot peaks
% and also peak-triggered average.

data_length = length(data);

segment_length=floor(no_target_cycles*sampling_freq/target_freq);
if mod(segment_length,2) == 0
    segment_length=segment_length+1;
end

Peak_segments = nan(length(Peak_locs), segment_length);

for i=1:length(Peak_locs)
    
    peak_location = Peak_locs(i);
        
    segment_start = max(1, peak_location-floor(segment_length/2));
    segment_end = min(data_length, peak_location+floor(segment_length/2));
    Peak_segments(i,:) = data(segment_start : segment_end)';
  
end

if ~isempty(filename)
   
    save([filename,'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.mat'],'Peak_locs','Peak_segments','peak_freq','target_freq','sampling_freq');
    
end