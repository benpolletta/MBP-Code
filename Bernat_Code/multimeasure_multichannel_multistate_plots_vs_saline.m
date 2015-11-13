function multimeasure_multichannel_multistate_plots_vs_saline(drug)

figure

freqs = 500*(1:2^9)/(2^10); freqs_plotted = freqs(freqs <= 200);

bonferroni_count = length(freqs_plotted);

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), load('states.mat'), load('drugs.mat'), load('subjects.mat')

PLV_c_order = [0 1 1; 1 .5 0; 1 0 1];

ticks = [1 8 30 60 140];

%% Plotting spectra.
    
[~, ~, spec_median, spec_ranksum] = drug_vs_saline_period_stats_by_state(channel_names, drug, 'post1to4', length(freqs_plotted), '', 'spec_pct_by_state'); % [spec_mean, spec_se, ~, ~] 
  
spec_test = spec_ranksum < .01/(3*4*2*all_dimensions(@sum, ~isnan(spec_ranksum)));

for st = 1:3
    
    subplot(5, no_states, st) % no_bands + 6, no_states, st)
    
    h = plot(freqs_plotted, -diff(spec_median(:, :, st, :), [], 4)); % boundedline(freqs_plotted(3:end)', spec_mean(3:end, :, st), spec_se(3:end, :, :, st)*norminv(1 - .05/bonferroni_count, 0, 1)); % spec_median(:, :, st), spec_med_cis(:, :, :, st)); %
    
    add_stars(gca, freqs_plotted, spec_test(:, :, st), [0 0 0], [])
    
    hold on,
    
    % h = plot(freqs_plotted, sal_spec_median(:, :, st), '--'); % boundedline(freqs_plotted(3:end)', sal_spec_mean(3:end, :, st), sal_spec_se(3:end, :, st)*norminv(1 - .05/bonferroni_count, 0, 1), ':'); % sal_spec_median(:, :, st), sal_spec_med_cis(:, :, :, st), '--');
    
    plot(freqs_plotted', zeros(size(freqs_plotted')), 'k--')
    
    set(gca, 'XScale', 'log', 'XTick', ticks, 'XTickLabel', ticks) % , 'YScale', 'log')
    
    axis tight
    
    % boundedline(freqs_plotted', spec_mean(:, :, st), spec_se(:, :, :, st)*norminv(1 - .05/bonferroni_count, 0, 1));
    
    title(long_states{st})
    
    xlabel('Freq. (Hz)')
    
    if st == 1, legend(h, channel_names), ylabel('z-Scored Power'), end
    
end

%% Plotting comodulograms.
    
[~, ~, MI_med, ~] = get_state_channel_period_stats(channel_names, drug, 'post1to4', no_afs*no_pfs, '_p0.99_IEzs', 'MI_pct_by_state');
    
MI_low = all_dimensions(@nanmin, MI_med);

MI_high = all_dimensions(@nanmax, MI_med);

for st = 1:3
    
    for c = 1:3
        
        subplot(5, no_states, c*no_states + st) % no_bands + 6, no_states, st)
        
        plotted_MI = reshape(MI_med(:, c, st), no_afs, no_pfs);
        
        imagesc(phase_freqs, amp_freqs, plotted_MI)
        
        caxis([MI_low MI_high])
        
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
    
[~, ~, PLV_median, PLV_ranksum] = drug_vs_saline_period_stats_by_state(chan_pair_names, drug, 'post1to4', no_afs + no_pfs, '', 'PLV_thresh_pct_by_state'); % [~, ~, sal_PLV_median, sal_PLV_med_cis] = get_state_channel_period_stats(chan_pair_names, 'saline', 'post1to4', no_afs + no_pfs, '', 'PLV_thresh_pct_by_state');

PLV_test = PLV_ranksum < .01/(3*4*2*all_dimensions(@sum, ~isnan(PLV_ranksum)));

band_freqs = {phase_freqs', amp_freqs'};

PLV_freqs = [phase_freqs, amp_freqs]';

band_indices = {PLV_freqs <= max(phase_freqs) & PLV_freqs >= min(phase_freqs), ...
    PLV_freqs <= max(amp_freqs) & PLV_freqs >= min(amp_freqs)};

for st = 1:3
    
    for b = 1:length(band_freqs)
        
        subplot(5, no_states, 4*no_states + st) % no_bands + 6, no_states, st)
                    
        set(gca, 'NextPlot', 'add', 'ColorOrder', PLV_c_order)
        
        h = plot(band_freqs{b}, -diff(PLV_median(band_indices{b}, :, st, :), [], 4));
        
        % boundedline(band_freqs{b}', PLV_median(band_indices{b}, :, st) - sal_PLV_median(band_indices{b}, :, st), PLV_med_cis(band_indices{b}, :, :, st)*norminv(1 - .05/bonferroni_count, 0, 1),...
        %    'cmap', PLV_c_order)
    
        % hold on,
        % 
        % h = boundedline(band_freqs{b}', zeros(size(PLV_median(band_indices{b}, :, st))), sal_PLV_med_cis(band_indices{b}, :, :, st)*norminv(1 - .05/bonferroni_count, 0, 1),...
        %     'cmap', PLV_c_order);
        
    end
        
    add_stars(gca, PLV_freqs, PLV_test(:, :, st), [0 0 0], PLV_c_order)
    
    hold on, plot(PLV_freqs, zeros(size(PLV_freqs)), 'k--')
    
    set(gca, 'XScale', 'log', 'XTick', ticks, 'XTickLabel', ticks) % , 'YScale', 'log')
    
    axis tight
    
    title(long_states{st})
    
    if st == 1, legend(h, display_chan_pair_names), ylabel('z-Scored PLV'), end
    
    xlabel('Freq. (Hz)')
    
end

% saveas(gcf, [drug, '_vs_saline_multichannel_multistate'])

saveas(gcf, [drug, '_vs_saline_multichannel_multistate.fig'])

end

function [state_mean, state_se, state_med, state_med_cis] = get_state_channel_period_stats(channel_names, drug, period, measure_size, measure_prefix, measure_name)

no_channels = length(channel_names);

load('states.mat'), load('drugs.mat'), load('subjects.mat')

if isempty(dir([measure_name, '_multichannel_multistate_stats_', drug, '_', period, '.mat']))
    
    state_med = nan(measure_size, 3, 3);
    
    state_med_cis = nan(measure_size, 2, 3, 3);
    
    state_mean = nan(measure_size, 3, 3);
    
    state_se = nan(measure_size, 1, 3, 3);
    
    for c = 1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];
        
        if ~isempty(dir([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.txt']))
        
            channel_spec = load([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.txt']);
        
        elseif ~isempty(dir([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.mat']))
            
            load([ch_dir, '/', ch_dir, measure_prefix, '_', measure_name, '.mat'])
            
            if exist('spec_pct', 'var')
            
                channel_spec = spec_pct;
            
            elseif exist('MI_pct', 'var') % exist('fourhrMI_pct', 'var')
                
                channel_spec = MI_pct; % fourhrMI_pct;
                
            elseif exist('PLV_pct', 'var')
                
                channel_spec = PLV_pct;
                
            end
            
        end
        
        spec_states = text_read([ch_dir, '/', ch_dir, measure_prefix, '_states.txt'], '%s');
        
        spec_drugs = text_read([ch_dir, '/', ch_dir, measure_prefix, '_drugs.txt'], '%s');
        
        spec_periods = text_read([ch_dir, '/', ch_dir, measure_prefix, '_4hrs.txt'], '%s');
        
        for st = 1:3
            
            state_indices = strcmp(spec_states, states{st}) & strcmp(spec_drugs, drug) & strcmp(spec_periods, period);
            
            state_spec_selected = channel_spec(state_indices, 1:measure_size);
            
            state_mean(:, c, st) = nanmean(state_spec_selected);
            
            state_se(:, :, c, st) = nanstd(state_spec_selected)/sqrt(size(state_spec_selected, 1));
            
            state_med(:, c, st) = nanmedian(state_spec_selected)';
            
            non_nan_indices = ~isnan(state_spec_selected(1, :)) | ~isnan(state_spec_selected(end, :)); 
            
            state_spec_selected(isnan(state_spec_selected(:, 1)), :) = []; 
            
            state_spec_selected(:, ~non_nan_indices) = [];
            
            matlabpool
            
            opt = statset('UseParallel', true);
            
            tic; state_med_ci = bootci(1000, {@nanmedian, state_spec_selected}, 'alpha', .05/measure_size, 'Options', opt); toc;
            
            matlabpool close
            
            state_med_cis(non_nan_indices, 1, c, st) = state_med_ci(1, :)'; %%%% Size problem here. (11/10/15)
            
            state_med_cis(non_nan_indices, 2, c, st) = state_med_ci(2, :)';
            
        end
        
    end
    
    state_se = repmat(state_se, [1 2 1 1]);
    
    save([measure_name, '_multichannel_multistate_stats_', drug, '_', period, '.mat'], 'state_mean', 'state_se', 'state_med', 'state_med_cis')
    
else
    
    load([measure_name, '_multichannel_multistate_stats_', drug, '_', period, '.mat'])
    
end

end