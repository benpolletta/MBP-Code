function [all_avg_fft,all_avg_se,MI_all,MI_all_thresh,AVP_all]=run_Satvinder(subject,channel)

sampling_freq=600;
nosecs=10;

challenge_labels={'Wake','NREM','REM','DREADD'};
no_challenges=length(challenge_labels);
subplot_dims=[1 4];

challenge_name=[subject,'_chan',num2str(channel)];

present_dir=pwd;
cd ([subject,'/',challenge_name])

challenge_list=[challenge_name,'_condition_lists.list'];
epoch_list=[challenge_name,'_epochs.list'];
for i=1:no_challenges
    condition_dirs{i}=[challenge_name,'_',challenge_labels{i}];
end

% challenge_list=[challenge_name,'_24hrs_condition_lists.list'];
% epoch_list=[challenge_name,'_24hrs_epochs.list'];
% for i=1:no_challenges
%     condition_dirs{i}=[challenge_name,'_',challenge_labels{i},'_24hrs'];
% end

challenge_descriptor=[subject,' Channel ',num2str(channel)];

tic; [all_avg_fft,all_avg_se]=avg_fft_save(challenge_list,sampling_freq,nosecs*sampling_freq,challenge_labels,subplot_dims); toc;
tic; wavelet_mouse_eeg_analysis_Jan_epsilon(sampling_freq,challenge_list,challenge_labels,{''},subplot_dims); toc;
tic; wavelet_mouse_eeg_canolty_MI(challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
tic; wavelet_mouse_eeg_PLV(sampling_freq,challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
tic; wavelet_mouse_eeg_file_shuffle([],0.95,sampling_freq,challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
stats_prompt=['STATS_FILE_SHUFFLE_',challenge_name,'*'];
tic; wavelet_mouse_eeg_threshold(stats_prompt,challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
% tic; wavelet_mouse_eeg_threshold('',challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
tic; [MI_all]=wavelet_mouse_eeg_collect_MI_struct(epoch_list,condition_dirs); toc;
tic; [MI_all_thresh]=wavelet_mouse_eeg_collect_MI_thresh(epoch_list,condition_dirs); toc;
tic; [AVP_all]=wavelet_mouse_eeg_collect_AVP_preferred_thresh(epoch_list,condition_dirs,1); toc;

cd (present_dir)