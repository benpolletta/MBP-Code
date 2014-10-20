function run_peak_avg_wt_Bernat

peak_freq_cycles = 3; sampling_freq = 1000;

load('subjects')
load('drugs')
load('channels')

% max_phase = get_peak_freqs;

peak_freqs = [2.25 6.5 8]; no_peak_freqs = length(peak_freqs);

for p = 2:no_peak_freqs
    
    for c = 1:no_channels
        
        for s = 1:no_subjects
            
            for d = 1:no_drugs
                
                record_dir = [subjects{s}, '_', drugs{d}];
                
                channel_dir = [record_dir, '_chan', num2str(location_channels{c}(s))];
                
                cd (['/home/bp/Bernat_NMDAR_antagonists/', record_dir])
                
                master_list = [channel_dir, '_epochs/', channel_dir, '_hours_master.list'];
                
                peak_averaged_wt_batch_condition_parallel(master_list, peak_freqs(p), peak_freq_cycles, sampling_freq);
                
                cd '/home/bp/Bernat_NMDAR_antagonists'
                
            end
            
        end
        
    end
    
end

end

function max_phase = get_peak_freqs

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat')

stats={'median','mean','std'}; no_stats = length(stats);

no_pre=4; no_post=12;
[hr_labels, ~, ~]=make_period_labels(no_pre,no_post,'hrs');
no_hr_periods = length(hr_labels);

All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_channels);

for c = 1:no_channels
    
    for d = 1:no_drugs
        
        load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_p0.99_IEzs_MI',...
            '/ALL_',channel_names{c},'_p0.99_IEzs_hr_',drugs{d},'_cplot_data.mat'])
        
        All_cplot_data(:, :, d, :, c) = MI_stats(:, :, 1, :, 1);
        
    end
    
end

max_phase_data = reshape(max(All_cplot_data), no_pfs, no_drugs, no_hr_periods, no_channels);

max_phase = nan(no_hr_periods, no_drugs, no_channels);

for c = 1:no_channels
    
    for d = 1:no_drugs
        
        for h = 1:no_hr_periods
           
            phase_profile = max_phase_data(:, d, h, c);
            
            [~, max_index] = max(phase_profile);
            
            max_phase(h, d, c) = phase_freqs(max_index);
            
        end
        
    end
    
end

max_phase = reshape(median(max_phase), no_drugs, no_hr_periods);

end