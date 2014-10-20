function run_subject_day_channel(subject,day,channel)

sampling_freq=400;
nosecs=4;

challenge_labels={'Wake','NREM','REM'};
challenge_params=[2,0,1];
subplot_dims=[1,3];

challenge_name=[subject,'_day',num2str(day),'_chan',num2str(channel)];

present_dir=pwd;
cd ([subject,'/Day_',num2str(day),'/',challenge_name])

challenge_list=[challenge_name,'_condition_lists.list'];
epoch_list=[challenge_name,'_epochs.list'];
for i=1:3
    condition_dirs{i}=[challenge_name,'_',challenge_labels{i}];
end

challenge_descriptor=[subject,' Day ',num2str(day),' Channel ',num2str(channel)];

all_avg_fft=avg_fft_condition_memory(challenge_list,sampling_freq,nosecs*sampling_freq,challenge_labels);
tic; wavelet_mouse_eeg_analysis_Jan_gamma(sampling_freq,challenge_list,challenge_labels,subplot_dims); toc;
tic; wavelet_mouse_eeg_canolty_MI(challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
tic; wavelet_mouse_eeg_PLV(sampling_freq,challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
tic; wavelet_mouse_eeg_file_shuffle([],0.95,sampling_freq,challenge_list,challenge_descriptor,challenge_labels); toc;
tic; wavelet_mouse_eeg_threshold('',challenge_list,challenge_descriptor,challenge_labels,subplot_dims); toc;
[MI_all]=wavelet_mouse_eeg_collect_MI_struct(epoch_list,condition_dirs);

cd (present_dir)
