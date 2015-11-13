function [state_mean, state_se, state_med, state_ranksum] = drug_vs_saline_period_stats_by_state(channel_names, drug, period, measure_size, measure_prefix, measure_name)

no_channels = length(channel_names);

load('states.mat'), load('drugs.mat'), load('subjects.mat')

if isempty(dir([measure_name, '_multichannel_multistate_ranksum_', drug, '_', period, '.mat']))
    
    state_med = nan(measure_size, 3, 3, 2);
    
    state_mean = nan(measure_size, 3, 3, 2);
    
    state_se = nan(measure_size, 1, 3, 3, 2);
    
    state_ranksum = nan(measure_size, 3, 3);
    
    for c = 1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];
        
        if ~isempty(dir([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.txt']))
        
            channel_spec = load([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.txt']);
        
        elseif ~isempty(dir([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.mat']))
            
            load([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.mat'])
            
            if exist('spec_pct', 'var')
            
                channel_spec = spec_pct;
            
            elseif exist('fourhrMI_pct', 'var')
                
                channel_spec = fourhrMI_pct;
                
            elseif exist('PLV_pct', 'var')
                
                channel_spec = PLV_pct;
                
            end
            
        end
        
        spec_states = text_read([ch_dir, '/', ch_dir, measure_prefix, '_states.txt'], '%s');
        
        spec_drugs = text_read([ch_dir, '/', ch_dir, measure_prefix, '_drugs.txt'], '%s');
        
        spec_periods = text_read([ch_dir, '/', ch_dir, measure_prefix, '_4hrs.txt'], '%s');
        
        for st = 1:3
            
            state_period_indices = strcmp(spec_states, states{st}) & strcmp(spec_periods, period);
            
            drug_spec_selected = channel_spec(state_period_indices & strcmp(spec_drugs, drug), 1:measure_size);
            
            saline_spec_selected = channel_spec(state_period_indices & strcmp(spec_drugs, 'saline'), 1:measure_size);
            
            state_mean(:, c, st, 1) = nanmean(drug_spec_selected);
            
            state_se(:, :, c, st, 1) = nanstd(drug_spec_selected)/sqrt(size(drug_spec_selected, 1));
            
            state_med(:, c, st, 1) = nanmedian(drug_spec_selected)';
            
            state_mean(:, c, st, 2) = nanmean(saline_spec_selected);
            
            state_se(:, :, c, st, 2) = nanstd(saline_spec_selected)/sqrt(size(drug_spec_selected, 1));
            
            state_med(:, c, st, 2) = nanmedian(saline_spec_selected)';
            
            for f = 1:measure_size
                
                if any(~isnan(drug_spec_selected(:, f))) && any(~isnan(saline_spec_selected(:, f)))
               
                    state_ranksum(f, c, st) = ranksum(drug_spec_selected(:, f), saline_spec_selected(:, f), 'tail', 'right');
                    
                end
                
            end
            
        end
        
    end
    
    state_se = repmat(state_se, [1 2 1 1 1]);
    
    save([measure_name, '_multichannel_multistate_ranksum_', drug, '_', period, '.mat'], 'state_mean', 'state_se', 'state_med', 'state_ranksum')
    
else
    
    load([measure_name, '_multichannel_multistate_ranksum_', drug, '_', period, '.mat'])
    
end

end