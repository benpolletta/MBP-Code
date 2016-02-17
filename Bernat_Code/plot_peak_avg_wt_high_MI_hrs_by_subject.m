function segment_lengths = plot_peak_avg_wt_high_MI_hrs_by_subject(start_index)

home_dir = '/projectnb/crc-nak/brpp';

[peak_hours, max_phase_freq, ~] = hour_peak_summed_MI_by_subject;

peak_freq_cycles = 3; sampling_freq = 1000;

load('subjects')
load('drugs')
load('channels')

if isempty(start_index), start_index = 0; end

index = 1;

segment_lengths = nan(no_subjects, no_drugs, 2);

for run = 1:2
    
    for s = 1:no_subjects
        
        for d = 1:no_drugs
            
            drug_phase_freq = max_phase_freq(s, d, run + 4);
            
            drug_segment_length=floor(peak_freq_cycles*sampling_freq/drug_phase_freq);
            if mod(drug_segment_length,2)==0
                drug_segment_length = drug_segment_length + 1;
            end
            
            segment_lengths(s, d, run) = drug_segment_length;
            
        end
        
    end
    
end

% All_mean_wt_phase = nan(200, , no_drugs, no_channels, no_subjects, 2);

% All_mean_wt_power = nan(200, , no_drugs, no_channels, no_subjects, 2);

for run = 1:2
    
    for s = 1:no_subjects
        
        for d = 1:no_drugs
            
            hr_label = sprintf('post%d', peak_hours(s, d, run + 4));
            
            drug_phase_freq = max_phase_freq(s, d, run + 4);
            
            record_dir = [subjects{s}, '_', drugs{d}, '_', hr_label, '_epochs'];
            
            cd ([home_dir, '/Bernat_NMDAR_antagonists/', record_dir])
            
            for c = 1:no_channels
                
                if index > start_index
                    
                    channel = location_channels{c}(s);
                    
                    channel_dir = [record_dir, '_chan', num2str(channel), '_peak-triggered_wt'];
                    
                    channel_wt_name = [record_dir, '_chan', num2str(channel), '_', num2str(drug_phase_freq), '_peak_wav.mat'];
                    
                    load([channel_dir, '/', channel_wt_name]);
                    
                    % All_mean_wt_power(:, :, d, c, s, run) = mean_wt_power;
                    
                    % All_mean_wt_phase(:, :, d, c, s, run) = mean_wt_phase;
                    
                    figure(1)
                    
                    subplot(no_channels, no_drugs, (c - 1)*no_drugs + d)
                    
                    imagesc(zscore(mean_wt_power')'), axis xy
                    
                    if c == 1, 
                        
                        if d ==1
                            
                            title([subjects{s}, ', ', drugs{d}, ', ', hr_label])
                            
                        else
                            
                            title([drugs{d}, ', ', hr_label])
                        
                        end
                            
                    end
                    
                    if d == 1, ylabel(channel_names{c}), end
                    
                    figure(2)
                    
                    subplot(no_channels, no_drugs, (c - 1)*no_drugs + d)
                    
                    imagesc(zscore(mean_wt_phase')'), axis xy
                    
                    if c == 1, title([drugs{d}, ', ', hr_label]), end
                    
                    if d == 1, ylabel(channel_names{c}), end
                    
                end
                
                index = index + 1;
                
            end
                    
            cd ([home_dir, '/Bernat_NMDAR_antagonists'])
            
        end
        
        save_as_pdf(1, [subjects{s}, '_', hr_label, 'peak_wt_power.pdf'])
        
        save_as_pdf(2, [subjects{s}, '_', hr_label, 'peak_wt_phase.pdf'])
        
        close('all')
        
    end
    
end

end

% function max_phase = get_peak_freqs
% 
% phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
% no_pfs = length(phase_freqs); no_afs = length(amp_freqs);
% 
% load('channels.mat'), no_channels = length(channel_names);
% 
% load('drugs.mat')
% 
% stats={'median','mean','std'}; no_stats = length(stats);
% 
% no_pre=4; no_post=12;
% [hr_labels, ~, ~]=make_period_labels(no_pre,no_post,'hrs');
% no_hr_periods = length(hr_labels);
% 
% All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_channels);
% 
% for c = 1:no_channels
%     
%     for d = 1:no_drugs
%         
%         load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_p0.99_IEzs_MI',...
%             '/ALL_',channel_names{c},'_p0.99_IEzs_hr_',drugs{d},'_cplot_data.mat'])
%         
%         All_cplot_data(:, :, d, :, c) = MI_stats(:, :, 1, :, 1);
%         
%     end
%     
% end
% 
% max_phase_data = reshape(max(All_cplot_data), no_pfs, no_drugs, no_hr_periods, no_channels);
% 
% max_phase = nan(no_hr_periods, no_drugs, no_channels);
% 
% for c = 1:no_channels
%     
%     for d = 1:no_drugs
%         
%         for h = 1:no_hr_periods
%            
%             phase_profile = max_phase_data(:, d, h, c);
%             
%             [~, max_index] = max(phase_profile);
%             
%             max_phase(h, d, c) = phase_freqs(max_index);
%             
%         end
%         
%     end
%     
% end
% 
% % max_phase = reshape(median(max_phase), no_drugs, no_hr_periods);
% 
% end