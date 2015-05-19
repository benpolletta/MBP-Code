function run_Bernat_simple(subject,drug,start_index)

sampling_freq=1000;

present_dir=pwd;

subject_dir=[subject,'_',drug];
cd (subject_dir)

challenge_list=[subject_dir,'_channels.list'];

channel_lists=textread(challenge_list,'%s');
no_channels=length(channel_lists);

channel_labels=cell(no_channels,1);
channels=cell(no_channels,1);
for c=1:no_channels
    channel_label=char(channel_lists(c));
    channel_labels{c}=channel_label;
    channel=channel_label((end-length('_epochs.list')):(end-length('_epochs.list')));
    channels{c}=channel;
end

subplot_dims=[1,no_channels];

challenge_descriptor=[subject,' ',drug];

tic; wavelet_mouse_eeg_analysis_Jan_epsilon(sampling_freq,challenge_list,channel_labels,{''},subplot_dims,start_index); toc;
% tic; wavelet_mouse_eeg_canolty_MI(challenge_list,challenge_descriptor,channel_labels,subplot_dims); toc;
% tic; wavelet_mouse_eeg_PLV(sampling_freq,challenge_list,challenge_descriptor,channel_labels,subplot_dims); toc;

noshufs=1000;
thresholds=[.05 .01 .001];

for c=1:no_channels
    
    drug_dir=pwd;
    
    channel_dir=channel_labels{c};
    channel_dir=channel_dir(1:end-5);
    cd (channel_dir)
    
    list_suffixes={'hours','4hrs_by_state'};
    no_master_lists=length(list_suffixes);
    
    for l=1:no_master_lists
        
        challenge_list=[channel_dir(1:end-length('_epochs')),'_',list_suffixes{l},'_master.list'];
        lists=textread(challenge_list,'%s');
        no_lists=length(lists);
        
        challenge_labels=cell(no_lists,1);
        for m=1:no_lists
            listname=char(lists(m));
            challenge_labels{m}=listname((length(channel_dir(1:end-length('_epochs')))+2):end-5);
        end
        
        [subplot_dims(1),subplot_dims(2)]=subplot_size(no_lists);
        
        challenge_descriptor=[subject,' ',drug,' Channel ',channels{c},' ',list_suffixes{l}];
        
        tic; wavelet_mouse_eeg_file_shuffle_IE(noshufs,thresholds,challenge_list); toc;
        tic; wavelet_mouse_eeg_threshold_IE(noshufs,challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
        
% %         tic; wavelet_mouse_eeg_file_shuffle_canolty_MI(noshufs,thresholds,challenge_list); toc;
% %         tic; wavelet_mouse_eeg_threshold_canolty_MI(noshufs,challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
%         tic; wavelet_mouse_eeg_file_shuffle_PLV(noshufs,thresholds,sampling_freq,challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;

%         [rows,cols]=subplot_size(no_lists);
        avg_fft_save(challenge_list,1000,4096*4) % ,challenge_labels,[rows,cols]);

        close('all')
        
    end
    
    cd (drug_dir)

end

cd (present_dir)

for c=1:no_channels

    wavelet_mouse_eeg_collect_IE_thresh_Bernat(subject,drug,channels{c},0.99)
    wavelet_mouse_eeg_collect_IE_thresh_by_state_Bernat(subject,drug,channels{c},0.99)
    wavelet_mouse_eeg_collect_AVP_Bernat(subject,drug,channels{c},[2.25 2.75 5.75 6.75],0)
    wavelet_mouse_eeg_collect_AVP_Bernat(subject,drug,channels{c},[2.25 2.75 5.75 6.75],1)
    
end
