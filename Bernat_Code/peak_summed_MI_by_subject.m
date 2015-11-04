function peak_hours = peak_summed_MI_by_subject

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