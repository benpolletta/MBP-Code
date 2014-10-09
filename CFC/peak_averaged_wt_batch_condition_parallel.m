function [mean_wt_power, mean_wt_phase, mean_peak_segments] = peak_averaged_wt_batch_condition_parallel(conditions_name, peak_freq, peak_freq_cycles, sampling_freq)

% Finds peaks in trace filtered at frequency peak_freq, spaced at least
% no_target_cycles cycles (at frequency target_freq) apart. Selects data
% segments around peaks, computes wavelet transform. Returns mean wavelet
% transform in a matrix.

segment_length=floor(peak_freq_cycles*sampling_freq/peak_freq);
if mod(segment_length,2)==0
    segment_length = segment_length + 1;
end
    
t=(1:segment_length)-floor(segment_length/2)-1;
t=t/sampling_freq;

freqs = 1:200;
no_freqs = length(freqs);

if isempty(conditions_name)

    [conditions_name,conditions_path]=uigetfile('*list','Choose a list of lists to calculate peak-averaged signal.');

else
    
    conditions_path = pwd;
    
end
    
condition_names=textread([conditions_path,conditions_name],'%s');
condition_num=length(condition_names);
list_legend = cell(condition_num,1);

[mean_wt_power, mean_wt_phase] = deal(nan(no_freqs, segment_length, condition_num));
mean_peak_segments=nan(segment_length,condition_num);

for c=1:condition_num
    
    listname=char(condition_names(c));
    list_legend{c} = listname(1:end-5);
    list_dir = [list_legend{c},'_peak-triggered_wt'];
    mkdir (list_dir)
    
    filenames=textread(listname,'%s');
    filenum=length(filenames);
    
    [All_wt_power, All_wt_phase] = deal(nan(no_freqs, segment_length, filenum));
    All_mean_peak_segments = nan(filenum, segment_length);
    no_peaks = nan(filenum, 1);
    
    parfor f=1:filenum
        
        filename=char(filenames(f));
        data=load(filename);
        
        [~, ~, file_wt_power, file_wt_phase, file_mean_peak_segment, file_peak_no] = peak_averaged_wavelet_transform(data, peak_freq, peak_freq_cycles, sampling_freq, 0, [list_dir,'/',filename(1:end-4)]);
        
        All_wt_power(:,:,f) = file_wt_power*file_peak_no;
        
        All_wt_phase(:, :, f) = file_wt_phase*file_peak_no;
        
        All_mean_peak_segments(f,:) = file_mean_peak_segment*file_peak_no;
        
        no_peaks(f)=file_peak_no;
        
    end
    
    save([list_dir,'/',listname(1:end-5),'_',num2str(peak_freq),'_peak_wav.mat'],'All_wt','All_mean_peak_segments','no_peaks','peak_freq','sampling_freq')

    mean_wt_power(:,:,c) = sum(All_wt_power,3)/sum(no_peaks);
    
    mean_wt_phase(:, :, c) = sum(All_wt_phase, 3)/sum(no_peaks);
    
    mean_peak_segments(:,c) = sum(All_mean_peak_segments)'/sum(no_peaks);
    
    figure;
    
    subplot(2,1,1)
    imagesc(t,freqs,zscore(mean_wt_power(:,:,c)')')
    c_axis = caxis;
    caxis([0 c_axis(2)])
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title([num2str(peak_freq),' Hz Peak-Triggered Wavelet Transform (Mean Power)'])
    
    subplot(2,1,2)
    imagesc(t,freqs,mean_wt_phase(:,:,c))
    c_axis = caxis;
    caxis([0 c_axis(2)])
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title([num2str(peak_freq),' Hz Peak-Triggered Wavelet Transform (Mean Phase)'])
    
    subplot(2,1,3)
    plot(t,mean_peak_segments(:,c))
    axis('tight'); box off;
    xlabel('Time (s)'); ylabel('mV');
    title([num2str(peak_freq),' Hz Peak-Triggered Mean Waveform'])
    
    save_as_pdf(gcf, [list_dir,'/',listname(1:end-5),'_',num2str(peak_freq),'_peak_wav'])
    
end

save([conditions_path,'/',conditions_name(1:end-5),'_',num2str(peak_freq),'_peak_wav.mat'],'mean_wt','mean_peak_segments')

wt_pow_max = max(max(max(zscore(mean_wt_power)))); %wt_pow_min = min(min(min(zscore(mean_wt_power))));

wt_phase_max = max(max(max(zscore(mean_wt_phase)))); %wt_phase_min = min(min(min(zscore(mean_wt_phase))));

[s_r, s_c] = subplot_size(condition_num);

figure;

for c = 1:condition_num

    subplot(s_r,s_c,c)
    imagesc(t,freqs,zscore(mean_wt_power(:,:,c)')')
    caxis([0 wt_pow_max])
    colorbar
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title({list_legend{c};[num2str(peak_freq),' Hz Peak-Triggered Wavelet Transform (Mean Power)']})
    
end

figure;

for c = 1:condition_num

    subplot(s_r,s_c,c)
    imagesc(t,freqs,mean_wt_phase(:,:,c))
    caxis([0 wt_phase_max])
    colorbar
    set(gca,'YDir','normal');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title({list_legend{c};[num2str(peak_freq),' Hz Peak-Triggered Wavelet Transform (Mean Phase)']})
    
end
    
save_as_pdf(gcf,[conditions_path,'/',conditions_name(1:end-5),'_',num2str(peak_freq),'_peak_wav'])