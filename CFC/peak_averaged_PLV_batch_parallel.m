function [mean_PLV, mean_peak_segments, total_peaks] = peak_averaged_PLV_batch_parallel(listnames, analysis_name, peak_freq, peak_freq_cycles, sampling_freq)

% Finds peaks in trace filtered at frequency peak_freq, spaced at least
% no_target_cycles cycles (at frequency target_freq) apart. Selects data
% segments around peaks, computes wavelet transform. Returns mean wavelet
% transform in a matrix.

mkdir(analysis_name)

segment_length=floor(peak_freq_cycles*sampling_freq/peak_freq);
if mod(segment_length,2)==0
    segment_length = segment_length + 1;
end
    
t=(1:segment_length)-floor(segment_length/2)-1;
t=t/sampling_freq;

freqs = 1:200;
no_freqs = length(freqs);

if isempty(listnames)

    [listnames{1}, ~]=uigetfile('*list', 'Choose first list of files to calculate peak-averaged signal.');

    [listnames{2}, conditions_path]=uigetfile('*list', 'Choose second list of files to calculate peak-averaged signal.');

else
    
    conditions_path = pwd;
    
end

mean_PLV = nan(no_freqs, segment_length);
mean_peak_segments = nan(segment_length, 1);

filenames = cell(2, 1); filenum = nan(2, 1);

for c=1:2
    
    filenames{c} = text_read([conditions_path, '/', listnames{c}],'%s');
    filenum(c) = length(filenames{c});
    
end

if range(filenum) == 0
    
    filenum = mean(filenum);
    
    All_PLV = nan(no_freqs, segment_length, filenum);
    All_mean_peak_segments = nan(filenum, segment_length, 2);
    no_peaks = nan(filenum, 1);
    
    parfor f=1:filenum
        
        data1 = load(filenames{1}{f});
        data2 = load(filenames{2}{f});
        
        [~, ~, file_PLV, file_mean_peak_segment, file_peak_no] = peak_averaged_PLV(data1, data2, peak_freq, peak_freq_cycles, sampling_freq, 0, '');
        
        All_PLV(:, :, f) = file_PLV*file_peak_no;
        
        All_mean_peak_segments(f, :, :) = reshape(file_mean_peak_segment, [1 size(file_mean_peak_segment)])*file_peak_no;
        
        no_peaks(f) = file_peak_no;
        
    end
    
    save([analysis_name,'/',analysis_name,'_',num2str(peak_freq),'_peak_PLV.mat'],...
        'All_PLV','All_mean_peak_segments','no_peaks','peak_freq','sampling_freq','peak_freq_cycles')

    total_peaks = sum(no_peaks);
    
    mean_PLV = sum(All_PLV,3)/sum(no_peaks);
    
    mean_peak_segments = reshape(sum(All_mean_peak_segments), [size(All_mean_peak_segments, 2) size(All_mean_peak_segments, 3)])'/sum(no_peaks);
    
    figure;
    
    subplot(2,1,1)
    imagesc(t,freqs,zscore(mean_PLV(:,:)')')
    c_axis = caxis;
    caxis([0 c_axis(2)])
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title([num2str(peak_freq),' Hz Peak-Triggered Phase-Locking Value (Mean)'])
    
    subplot(2,1,2)
    plot(t,mean_peak_segments)
    axis('tight'); box off;
    xlabel('Time (s)'); ylabel('mV');
    title([num2str(peak_freq),' Hz Peak-Triggered Mean Waveform'])
    legend(listnames)
    
    save_as_pdf(gcf, [analysis_name,'/',analysis_name,'_',num2str(peak_freq),'_peak_PLV'])
   
else
    
    display('The two lists given in the cell listnames must contain the same number of elements.')
    
    return
    
end