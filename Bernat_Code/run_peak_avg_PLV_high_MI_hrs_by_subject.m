function run_peak_avg_PLV_high_MI_hrs_by_subject(channel_labels, start_index)

home_dir = '/projectnb/crc-nak/brpp';

[peak_hours, max_phase_freq, ~] = hour_peak_summed_MI_by_subject;

peak_freq_cycles = 3; sampling_freq = 1000;

load('subjects')
load('drugs')
load('channels')

channel_index = nan(2, 1);

for ch = 1:2
   
    channel_index(ch) = find(strcmp(channel_names, channel_labels{ch}));
    
end

if isempty(start_index), start_index = 0; end

index = 1;

for run = 1:2
    
    for s = 1:no_subjects
        
        for d = 1:no_drugs
            
            if index > start_index
                
                hr_label = sprintf('post%d', peak_hours(s, d, run + 4));
                
                hr_phase = max_phase_freq(s, d, run + 4);
                
                record_dir = [subjects{s}, '_', drugs{d}, '_', hr_label, '_epochs'];
                
                analysis_name = [subjects{s}, '_', drugs{d}, '_', hr_label,...
                    '_chan', num2str(location_channels{channel_index(1)}(s)),...
                    '_chan', num2str(location_channels{channel_index(2)}(s)), '_peak-triggered_PLV'];
                
                cd ([home_dir, '/Bernat_NMDAR_antagonists/', record_dir])
                
                channel_listnames = cell(1, 2);
                
                for ch = 1:2
                    
                    channel = location_channels{channel_index(ch)}(s);
                    
                    channel_listnames{ch} = [record_dir, '_chan', num2str(channel), '.list'];
                    
                    if isempty(dir(channel_listnames{ch}))
                        
                        load([record_dir, '_numbers.mat'])
                        
                        fid = fopen(channel_listnames{ch}, 'w');
                        
                        for e = 1:length(epoch_numbers)
                            
                            epoch_filename = [subjects{s}, '_', drugs{d}, '_chan', num2str(channel), '_epoch', num2str(epoch_numbers(e)), '.txt'];
                            
                            fprintf(fid, '%s\n', epoch_filename);
                            
                        end
                        
                        fclose(fid);
                        
                    end
                    
                    
                end
                
                peak_averaged_PLV_batch_parallel(channel_listnames, analysis_name, hr_phase, peak_freq_cycles, sampling_freq);
        
                cd ([home_dir, '/Bernat_NMDAR_antagonists'])
                
            end
            
            index = index + 1;
            
        end
        
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