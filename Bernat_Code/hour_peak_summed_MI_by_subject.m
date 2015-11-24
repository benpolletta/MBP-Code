function [peak_hours, max_phase_freq, max_amp_freq] = hour_peak_summed_MI_by_subject

load('channels.mat'), load('drugs.mat'), load('subjects.mat'), load('AP_freqs.mat')

phase_interval = {[1 4], [6 11]}; amp_interval = {[40 80], [80 120], [120 180]};
    
no_bands = length(phase_interval)*length(amp_interval);

peak_hours = nan(subj_num, no_drugs - 1, no_bands);

for s = 1:subj_num
    
    All_BP_stats = nan(24, no_drugs, 6, no_channels);
   
    for c = 1:no_channels
        
        load(sprintf('ALL_%s/ALL_%s_%s_summed_hrMI_hr_BP_stats.mat', channel_names{c}, channel_names{c}, subjects{s}))
        
        BP_stats = permute(BP_stats(:, :, 3, :), [2 4 1 3]);
        
        All_BP_stats(:, :, :, c) = permute_fit(All_BP_stats(:, :, :, c), BP_stats);
        
    end
    
    All_BP_stats = nanmax(All_BP_stats, [], 4);
    
    % figure, for b = 1:no_bands, subplot(3, 2, b), plot(All_BP_stats(:,:,b)), axis tight, end
    
    for d = 2:4
        
        for b = 1:no_bands
            
            [~, peak_hours(s, d - 1, b)] = nanmax(All_BP_stats(5:12, d, b));
            
        end
        
    end
    
end

[max_phase_freq, max_amp_freq] = get_peak_freqs(peak_hours, amp_interval, phase_interval);

end

function [max_phase, max_amp] = get_peak_freqs(peak_hours, amp_interval, phase_interval)

load('channels.mat'), load('drugs.mat'), load('subjects.mat'), load('AP_freqs.mat')
    
no_bands = length(phase_interval)*length(amp_interval);

[phase_range, amp_range] = deal(cell(no_bands, 1));

for b = 1:no_bands

    phase_range{b} = phase_freqs >= phase_interval{2 - mod(b, 2)}(1) & phase_freqs <= phase_interval{2 - mod(b, 2)}(2);
    
    amp_range{b} = amp_freqs >= amp_interval{ceil(b/2)}(1) & amp_freqs <= amp_interval{ceil(b/2)}(2); % mod(b - 1, 3) + 1
    
end

All_cplot_data = nan(no_afs, no_pfs, no_drugs - 1, no_subjects, no_channels, no_bands);

for c = 1:no_channels
    
    for d = 2:no_drugs
        
        for s = 1:subj_num
        
            load(['ALL_', channel_names{c}, '/ALL_', channel_names{c}, '_p0.99_IEzs_MI',...
                '/ALL_', channel_names{c}, '_p0.99_IEzs_hr_', subjects{s}, '_', drugs{d}, '_cplot_data.mat'])
            
            for b = 1:no_bands
                
                All_cplot_data(:, :, d - 1, s, c, b) = MI_stats(:, :, :, peak_hours(s, d - 1, b));
                
            end
        
        end
        
    end
    
end
    
[max_phase, max_amp] = deal(nan(subj_num, no_drugs - 1, no_bands));
        
for b = 1:no_bands
    
    phase_freq_range = phase_freqs(phase_range{b});
    
    amp_freq_range = amp_freqs(amp_range{b});
    
    max_phase_data = nanmax(nanmax(All_cplot_data(amp_range{b}, :, :, :, b), [], 5));
    
    max_phase_data = reshape(max_phase_data, no_pfs, no_drugs - 1, subj_num);
    
    for d = 1:(no_drugs - 1)
        
        for s = 1:subj_num
            
            phase_profile = max_phase_data(phase_range{b}, d, s);
            
            [~, max_phase_index] = nanmax(phase_profile);
            
            max_phase(s, d, b) = phase_freq_range(max_phase_index);
            
            amp_profile = nanmax(All_cplot_data(amp_range{b}, max_phase_index, d, s, :, b), [], 5);
            
            [~, max_amp_index] = nanmax(amp_profile);
            
            max_amp(s, d, b) = amp_freq_range(max_amp_index);
            
        end
        
    end
    
end

end