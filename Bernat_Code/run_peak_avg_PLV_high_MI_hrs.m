function run_peak_avg_PLV_high_MI_hrs(channel_labels, start_index)

high_MI_hrs = [4 2 4 7];

peak_freq_cycles = 3; sampling_freq = 1000;

load('subjects')
load('drugs')
load('channels')

channel_index = nan(2, 1);

for ch = 1:2
   
    channel_index(ch) = find(strcmp(channel_names, channel_labels{ch}));
    
end

no_pre=4; no_post=12;
[hr_labels, ~, ~]=make_period_labels(no_pre,no_post,'hrs');
no_hr_periods = length(hr_labels);

max_phase = get_peak_freqs;

if isempty(start_index), start_index = 0; end

index = 1;
    
for s = 1:no_subjects
                
    subj_channels = nan(2, 1);
    
    for ch = 1:2
        
        subj_channels(ch) = location_channels{channel_index(ch)}(s);
        
    end
    
    for dr = 1:no_drugs
        
        if index > start_index
            
            index = index + 1;
            
            record_dir = [subjects{s}, '_', drugs{dr}];
            
            cd (['/home/bp/Bernat_NMDAR_antagonists/', record_dir])
            
            for hr = high_MI_hrs(dr) + 4 
                
                pd_lists = cell(2, 1);
                
                for ch = 1:2
                    
                    pd_lists{ch} = [record_dir, '_chan', num2str(subj_channels(ch)), '_', hr_labels{hr}, '.list'];
                
                end
                    
                if ~isempty(dir(pd_lists{1})) && ~isempty(dir(pd_lists{2}))
                
                    analysis_name = [record_dir, '_chan', num2str(subj_channels(1)), '_chan', num2str(subj_channels(2)), '_', hr_labels{hr}];
                    
                    peak_averaged_PLV_batch_parallel(pd_lists, analysis_name, max_phase(hr, dr, channel_index(1)), peak_freq_cycles, sampling_freq)
                    
                end
                
            end
            
            cd '/home/bp/Bernat_NMDAR_antagonists'
            
        end
        
    end
    
end

end

function max_phase = get_peak_freqs

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat')

load('drugs.mat')

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

%max_phase = reshape(median(max_phase), no_drugs, no_hr_periods);

end