function MI_multichannel_multistate_plots(drug)

figure

freqs = 500*(1:2^9)/(2^10); freqs_plotted = freqs(freqs <= 200);

bonferroni_count = length(freqs_plotted);

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), load('states.mat'), load('drugs.mat'), load('subjects.mat')

PLV_c_order = [0 1 1; 1 .5 0; 1 0 1];
    
clear titles xlabels ylabels

ticks = [1 8 30 60 140];

%% Plotting spectra.
    
[spec_mean, spec_se, ~, ~] = get_state_channel_stats(channel_names, drug, length(freqs_plotted), '', 'spec_zs');
    
for st = 1:3
    
    subplot(5, no_states, st) % no_bands + 6, no_states, st)
    
    for reps = 1:2
    
        h = boundedline(freqs_plotted', spec_mean(:, :, st), spec_se(:, :, :, st)*norminv(1 - .05/bonferroni_count, 0, 1));
    
    end
    
    hold on, plot(freqs_plotted', zeros(size(freqs_plotted')), 'k--')
    
    set(gca, 'XScale', 'log', 'XTick', ticks, 'XTickLabel', ticks) % , 'YScale', 'log')
    
    axis tight
    
    title(long_states{st})
    
    xlabel('Freq. (Hz)')
    
    if st == 1, legend(h, channel_names), ylabel('z-Scored Power'), end
    
end

%% Plotting comodulograms.
    
[~, ~, MI_med, ~] = get_state_channel_stats(channel_names, drug, no_afs*no_pfs, '_p0.99_IEzs', 'hr_MI_pct');
    
MI_low = all_dimensions(@nanmin, MI_med);

MI_high = all_dimensions(@nanmax, MI_med);

for st = 1:3
    
    for c = 1:3
        
        subplot(5, no_states, c*no_states + st) % no_bands + 6, no_states, st)
        
        plotted_MI = reshape(MI_med(:, c, st), no_afs, no_pfs);
        
        imagesc(phase_freqs, amp_freqs, plotted_MI)
        
        colorbar % caxis([MI_low MI_high])
        
        axis xy
        
        % if c == 1, title(states{st}), end
        
        if st == 1, ylabel({'Modulation Index'; channel_names{c}; 'f_a (Hz)'}), end
        
        if c == 3, xlabel('f_p (Hz)'), end
        
    end
    
end

%% Plotting PLV.

chan_pairs = nchoosek(1:3, 2);

[chan_pair_names, display_chan_pair_names] = deal(cell(3,1));

for p = 1:3,
    
    chan_pair_names{p} = sprintf('%s_by_%s', channel_names{chan_pairs(p, 1)}, channel_names{chan_pairs(p,2)});
    
    display_chan_pair_names{p} = sprintf('%s by %s', display_channel_names{chan_pairs(p, 1)}, display_channel_names{chan_pairs(p,2)});
    
end
    
[PLV_mean, PLV_se, ~, ~] = get_state_channel_stats(chan_pair_names, drug, no_afs + no_pfs, '', 'PLV_zs');

band_freqs = {phase_freqs, amp_freqs};

PLV_freqs = [phase_freqs, amp_freqs];

band_indices = {PLV_freqs <= max(phase_freqs) & PLV_freqs >= min(phase_freqs), ...
    PLV_freqs <= max(amp_freqs) & PLV_freqs >= min(amp_freqs)};

for st = 1:3
    
    for b = 1:length(band_freqs)
        
        subplot(5, no_states, 4*no_states + st) % no_bands + 6, no_states, st)
        
        h = boundedline(band_freqs{b}', PLV_mean(band_indices{b}, :, st), PLV_se(band_indices{b}, :, :, st)*norminv(1 - .05/bonferroni_count, 0, 1),...
            'cmap', PLV_c_order);
        
        hold on, plot(band_freqs{b}', zeros(size(band_freqs{b}')), 'k--')
        
        set(gca, 'XScale', 'log', 'XTick', ticks, 'XTickLabel', ticks) % , 'YScale', 'log')
        
        axis tight
        
        title(long_states{st})
        
        if st == 1, legend(h, display_chan_pair_names), ylabel('z-Scored PLV'), end
        
        xlabel('Freq. (Hz)')
        
    end
    
end

% saveas(gcf, [drug, '_multichannel_multistate'])

saveas(gcf, [drug, '_multichannel_multistate.fig'])

end

function [state_mean, state_se, state_med, state_med_cis] = get_state_channel_stats(channel_names, drug, measure_size, measure_prefix, measure_name)

no_channels = length(channel_names);

load('states.mat'), load('drugs.mat'), load('subjects.mat')

if isempty(dir([measure_name, '_multichannel_multistate_stats_', drug, '.mat']))
    
    state_med = nan(measure_size, 3, 3);
    
    state_med_cis = nan(measure_size, 2, 3, 3);
    
    state_mean = nan(measure_size, 3, 3);
    
    state_se = nan(measure_size, 1, 3, 3);
    
    for c = 1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];
        
        channel_spec = load([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.txt']);
        
        spec_states = text_read([ch_dir, '/', ch_dir, measure_prefix, '_states.txt'], '%s');
        
        spec_drugs = text_read([ch_dir, '/', ch_dir, measure_prefix, '_drugs.txt'], '%s');
        
        spec_subjects = text_read([ch_dir, '/', ch_dir, measure_prefix, '_subjects.txt'], '%s');
        
        for st = 1:3
            
            state_indices = strcmp(spec_states, states{st}) & strcmp(spec_drugs, drug);
            
            state_spec = channel_spec(state_indices, 1:measure_size);
            
            state_subjects = spec_subjects(state_indices);
            
            state_spec_selected = nan(subj_num*220, measure_size);
            
            for su = 1:subj_num
               
                subj_indices = strcmp(state_subjects, subjects{su});
                
                % subj_indices_center = subj_indices'*(1:length(subj_indices))'/sum(subj_indices);
                % 
                % subj_indices_chosen_start = floor(subj_indices_center - 110)
                
                subj_state_spec = state_spec(subj_indices, :);
                
                subj_indices_chosen_start = floor(size(subj_state_spec, 1)/2 - 110);
                
                state_spec_selected(((su - 1)*220 + 1):su*220, :) = subj_state_spec(subj_indices_chosen_start + (1:220), :);
                
            end
            
            state_mean(:, c, st) = nanmean(state_spec_selected);
            
            state_se(:, :, c, st) = nanstd(state_spec_selected)/sqrt(size(state_spec_selected, 1));
            
            state_med(:, c, st) = nanmedian(state_spec_selected)';
            
            non_nan_indices = ~isnan(state_spec_selected(1, :));
            
            state_spec_selected(isnan(state_spec_selected(:, 1)), :) = [];
            
            state_spec_selected(:, isnan(state_spec_selected(1, :))) = [];
            
            matlabpool
            
            opt = statset('UseParallel', true);
            
            tic; state_med_ci = bootci(1000, {@nanmedian, state_spec_selected}, 'alpha', .05/measure_size, 'Options', opt); toc;
            
            matlabpool close
            
            state_med_cis(non_nan_indices, 1, c, st) = state_med_ci(1, :)';
            
            state_med_cis(non_nan_indices, 2, c, st) = state_med_ci(2, :)';
            
        end
        
    end
    
    state_se = repmat(state_se, [1 2 1 1]);
    
    save([measure_name, '_multichannel_multistate_stats_', drug, '.mat'], 'state_mean', 'state_se', 'state_med', 'state_med_cis')
    
else
    
    load([measure_name, '_multichannel_multistate_stats_', drug, '.mat'])
    
end

end