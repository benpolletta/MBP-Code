function run_Bernat(subject,channel)

sampling_freq=1000;
nosecs=4096/250;
signal_length=nosecs*sampling_freq;

period_labels={'Preinjection','Hrs 1 - 4 Postinjection','Hrs 5 - 8 Postinjection'};
drug_labels={'MK801','NVP','Ro25','Saline'};
for i=1:length(drug_labels)
    for j=1:length(period_labels)
        condition_labels{(i-1)*3+j}=[drug_labels{i},' ',period_labels{j}];
    end
end

subplot_dims=[4,3];

present_dir=pwd;

state_labels={'R','NR','AW'};
no_states=length(state_labels);

for i=1:3
    
    challenge_name=[subject,'_chan',num2str(channel),'_',state_labels{i}];

    condition_dirs{i}=challenge_name;
    
    cd (challenge_name)

    challenge_list=[challenge_name,'_periods.list'];

    challenge_descriptor=[subject,' ',state_labels{i},', Channel ',num2str(channel)];

    tic; [all_avg_fft,all_avg_se]=avg_fft_save(challenge_list,sampling_freq,nosecs*sampling_freq,condition_labels); toc;
    tic; wavelet_mouse_eeg_analysis_Jan_epsilon(sampling_freq,challenge_list,period_labels,drug_labels,subplot_dims); toc;
    tic; wavelet_mouse_eeg_canolty_MI(challenge_list,challenge_descriptor,condition_labels,subplot_dims); toc;
    tic; wavelet_mouse_eeg_PLV(sampling_freq,challenge_list,challenge_descriptor,condition_labels,subplot_dims); toc;
    tic; wavelet_mouse_eeg_file_shuffle(1000,0.95,sampling_freq,challenge_list,challenge_descriptor,condition_labels,subplot_dims); toc;
    stats_prompt=['STATS_FILE_SHUFFLE_',challenge_name,'*'];
    tic; wavelet_mouse_eeg_threshold(stats_prompt,challenge_list,challenge_descriptor,condition_labels,subplot_dims); toc;
    
    cd (present_dir)

end

tic; wavelet_mouse_eeg_collect_Bernat_summed(subject,channel,[110 180],[6 9]); toc;
tic; wavelet_mouse_eeg_collect_Bernat_summed(subject,channel,[60 90],[6 9]); toc;
tic; wavelet_mouse_eeg_collect_Bernat_summed(subject,channel,[20 50],[6 9]); toc;
tic; wavelet_mouse_eeg_compute_power_Bernat(subject,channel); toc;

% 
% band_limits=[.1 4; 4 8; 10 13; 15 30; 35 59; 61 110; 125 175];
% band_labels={'delta','theta','alpha','beta','low-gamma','high-gamma','HFOs'};
% 
% for i=1:4
%     
%     data_dir=[subject,'_',drug_labels{i},'_chan',num2str(channel)];
%         
%     epoch_list=[data_dir,'_epochs.list'];
%     
%     tic; wavelet_mouse_eeg_collect_power(sampling_freq,signal_length,epoch_list,data_dir,band_limits,band_labels); toc;
%     
% end