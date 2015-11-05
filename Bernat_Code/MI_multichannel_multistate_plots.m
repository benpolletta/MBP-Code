function MI_multichannel_multistate_plots(drug)

freqs = 500*(1:2^9)/(2^10); freqs_plotted = freqs(freqs <= 200);

bonferroni_count = length(freqs_plotted);

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), no_channels = length(channel_names);

load('states.mat'), no_states = length(states);

load('drugs.mat')

stats={'median','mean','std'}; no_stats = length(stats);
long_stats={'Median','Mean','St. Dev.'}; total_stats = 5;

norms={'', '_pct'}; no_norms = length(norms);
long_norms={'', '% Change'};% From Baseline'};

no_pre=4; no_post=12;
[hr_labels, ~, long_hr_labels] = make_period_labels(no_pre, no_post, 'hrs');
no_hr_periods = length(hr_labels);

no_pre=4; no_post=16;
[BP_hr_labels, ~, ~] = make_period_labels(no_pre, no_post, 'hrs');
no_BP_hr_periods = length(BP_hr_labels);
short_BP_hr_labels = -4:16; short_BP_hr_labels(short_BP_hr_labels == 0) = [];

tick_spacing = floor(no_BP_hr_periods/5);

no_bands = 6;
            
bands_plotted = [2 5 6]; no_bands_plotted = length(bands_plotted);

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels

%% Plotting spectra.
    
if isempty(dir(['spec_multichannel_multistate_median.mat']))
    
    for c = 1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];channel_spec = load([ch_dir, '/', ch_dir, '_spec.txt']);
        
        spec_states = text_read([ch_dir, '/', ch_dir, '_states.txt'], '%s');
        
        spec_drugs = text_read([ch_dir, '/', ch_dir, '_drugs.txt'], '%s');
        
        state_med = nan(size(channel_spec, 2), 3, 3);
        
        state_med_cis = nan(size(channel_spec, 2), 2, 3, 3);
        
        for s = 1:3
            
            state_indices = strcmp(spec_states, states{s}) & strcmp(spec_drugs, drug);
            
            state_spec = channel_spec(state_indices, freqs <= 200);
            
            non_nan_indices = ~isnan(state_spec(1, :));
            
            state_spec(isnan(state_spec(:, 1)), :) = [];
            
            state_spec(:, isnan(state_spec(1, :))) = [];
            
            state_med(non_nan_indices, c, s) = nanmedian(state_spec)';
            
            matlabpool
            
            opt = statset('UseParallel', true);
            
            tic; state_med_ci = bootci(100, {@nanmedian, state_spec}, 'alpha', .05/bonferroni_count, 'Options', opt); toc;
            
            matlabpool close
            
            state_med_cis(non_nan_indices, 1, c, s) = state_med_ci(1, :)';
            
            state_med_cis(non_nan_indices, 2, c, s) = state_med_ci(2, :)';
            
        end
        
    end
    
    save('spec_multichannel_multistate_median.mat', 'state_med', 'state_med_cis')
    
else
    
    load('spec_multichannel_multistate_median.mat')
    
end
    
    
for s = 1:3
    
    subplot(5, no_states, s)
    
    boundedline(freqs_plotted', state_med(:, :, s), state_med_cis(:, :, :, s))
    
end
