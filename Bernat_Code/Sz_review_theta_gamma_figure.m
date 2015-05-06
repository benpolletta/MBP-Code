function Sz_review_theta_gamma_figure(subject, drug, channel, epoch)

subject = 'A99'; drug = 'saline'; channel = 6; epoch = 1000;

sample = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subject, drug, subject, drug, channel, epoch));

sample_gamma = eegfilt(sample', 1000, 60, 100)'; %wavelet_spectrogram(sample, 1000, 85, 9, 0, '');

sample_theta = eegfilt(sample', 1000, 6, 11)'; %wavelet_spectrogram(sample, 1000, 8, 9, 0, '');

indices = (3520:4020);

figure

subplot(2, 1, 1)

plot(indices/1000, sample(indices))

axis tight

subplot(2, 1, 2)

ax = plotyy(indices/1000, real(sample_theta(indices)), indices/1000, real(sample_gamma(indices)));

axis(ax(1), 'tight'), axis(ax(2), 'tight')
    
% for i = 1:15
% 
%     indices = (1:1000) + (i - 1)*1000; 
%     
%     subplot(5,3,i)
%     
%     plotyy(t, real(sample_theta(indices)), t, real(sample_gamma(indices))) 
% 
% end

% channel_label = 'CA1'; measure = 'p0.99_IEzs';
% 
% % subjects={'A99','A102','A103','A104','A105','A106'};
% % subj_num=length(subjects);
% 
% state_labels={'W','NR','R'};
% % no_states=length(state_labels);
% 
% drug_labels={'saline','MK801','NVP','Ro25'};
% % no_drugs=length(drug_labels);
% 
% name=['ALL_',channel_label];
% 
% drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
% subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
% %hrs = text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
% %fourhrs = text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
% sixmins = text_read([name,'/',name,'_',measure,'_6min_periods.txt'],'%s');
% %states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
% %load([name,'/',name,'_',measure,'_summed.mat'])
% load([name,'/',name,'_',measure,'_summed_pct.mat'])
% 
% max_MI_index = find(max(summed_MI_pct(:, 2)));
% 
% max_MI_subject = subjects{max_MI_index}
% 
% max_MI_drug = drugs{max_MI_index}
% 
% max_MI_sixmins = sixmins{max_MI_index}



