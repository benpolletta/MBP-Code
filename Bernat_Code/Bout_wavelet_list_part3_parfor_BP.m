function Bout_wavelet_list_part3_parfor_BP

sampling_freq=1000;

nophases=31;

no_amp_bands=[51 51 46];
no_amps=length(no_amp_bands);
band_ranges=[35 60; 60 110; 110 200];
amp_titles={'low_gamma','high_gamma','HFO'};

noshufs=100;%0;
threshold=0.99;

[listname,listpath]=uigetfile('*bouts.list','Choose a bout list to run REM MI analysis.');
filenames=textread([listpath, listname],'%s%*[^\n]');
mkdir(listpath, [listname(1:end-5), '_MI']);

for i=1:length(filenames)

    filename=char(filenames(i));
    data=load(filename);
        
    [P_bands, ~, ~, P_theta]=filter_wavelet_Jan(data,'fs', sampling_freq, 'nobands', nophases, 'bandrange', [4 10]);
    P_bands=P_bands(:,2);
    
    for a=1:no_amps
        
        tic;
        MI_stats=IE_sliding_window_shuffle(noshufs, threshold, data, sampling_freq, no_amp_bands(a), band_ranges(a,:), P_theta, P_bands, listname, filename, amp_titles{a});
        toc;
        
        tic;
        IE_sliding_window_memory(data, sampling_freq, no_amp_bands(a), band_ranges(a,:), P_theta, P_bands, listname, filename, amp_titles{a}, MI_stats)
        toc;

%         tic;
%         IE_sliding_window(data, sampling_freq, no_amp_bands(a), band_ranges(a,:), P_theta, P_bands, listname, filename, amp_titles{a}, MI_stats);
%         toc;
        
        
    end
    
end