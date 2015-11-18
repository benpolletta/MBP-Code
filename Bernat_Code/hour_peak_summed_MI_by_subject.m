function peak_hours = hour_peak_summed_MI_by_subject

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat'), no_drugs = length(drugs);

load('subjects.mat'), subj_num = length(subjects);

peak_hours = nan(subj_num, no_drugs - 1);

band_id = [6 5 6];

for s = 1:subj_num
    
    All_BP_stats = nan(24, no_drugs, 6, no_channels);
   
    for c = 1:no_channels
        
        load(sprintf('ALL_%s/ALL_%s_%s_summed_hrMI_hr_BP_stats.mat', channel_names{c}, channel_names{c}, subjects{s}))
        
        BP_stats = permute(BP_stats(:, :, 3, :), [2 4 1 3]);
        
        All_BP_stats(:, :, :, c) = permute_fit(All_BP_stats(:, :, :, c), BP_stats);
        
    end
    
    All_BP_stats = max(All_BP_stats, 4);
    
    for d = 2:4
        
        [~, peak_hours(s, d - 1)] = max(All_BP_stats(:, d, band_id(d - 1)));
        
    end
    
end

peak_hours = peak_hours - 4;

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

% max_phase = reshape(median(max_phase), no_drugs, no_hr_periods);

end