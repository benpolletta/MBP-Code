function max_freq(data,sampling_freq,filename,dirname,nobands,bandrange,time_resol)

%Takes each bout and does wavelets over 4-10Hz, 50 bands.

[bands,~,A,P]=filter_wavelet_Jan(data,'fs',sampling_freq,'nobands',nobands,'bandrange',bandrange,'time_resol',time_resol);

center_freqs=bands(:,2);
[max_amp,index_for_max_amp]=max(A');
freq_for_max_amp=center_freqs(index_for_max_amp);

A_norm=(A-ones(size(A))*diag(mean(A)))*(1./diag(std(A)));
[max_norm_amp,index_for_max_norm_amp]=max(A_norm');
freq_for_max_norm_amp=center_freqs(index_for_max_norm_amp);

if ~isempty(dirname)
    if ~isempty(filename)
        save([dirname, '/', filename, '_HAP'], 'A', 'P', 'max_amp', 'freq_for_max_amp', 'max_amp', 'freq_for_max_amp');
    else
        save([dirname, '/HAP'], 'A', 'P', 'max_amp', 'freq_for_max_amp', 'max_amp', 'freq_for_max_amp');
    end
else
    if ~isempty(filename)
        save([filename, '_HAP'], 'A', 'P', 'max_amp', 'freq_for_max_amp', 'max_amp', 'freq_for_max_amp');
    else
        save(['HAP'], 'A', 'P', 'max_amp', 'freq_for_max_amp', 'max_amp', 'freq_for_max_amp');
    end
end
