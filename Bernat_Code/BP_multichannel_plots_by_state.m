function BP_multichannel_plots_by_state

c_order = [.5 .5 .5; 1 .75 0; 1 0 1; 0 1 1];

short_state_labels = {'W','NR','R'}; state_labels = {'AW','QW/NR','R'};
no_states = length(state_labels);

stat_labels={'median','Q1','Q3','mean','std'};
no_stats=length(stat_labels);

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat'), no_drugs = length(drugs);

norms = {'_', '_pct_'}; no_norms = length(norms); long_norms = {'', ', Pct. of Baseline'};

periods = {'hrs', '6min'}; no_pds = length(periods);

mat_labels = {'by_state', 'BP_stats'};

stat_indices = [1 4]; stat_labels = {'Median', 'Mean'};

%% Plots by time (not broken down by state).

for n = 1:no_norms
    
    for p = 1:no_pds
        
        suffix = [norms{n}, periods{p}, '_', mat_labels{1}];
        
        ranksum_suffix = [norms{n}, periods{p}, '_', mat_labels{1}, '_ranksum'];
        
        clear All_BP_stats All_BP_ranksum
        
        for ch = 1:no_channels
            
            ch_dir = ['ALL_', channel_names{ch}];
            
            load([ch_dir, '/', ch_dir, '_BP', suffix, '.mat'])
            
            BP_stats_new = permute(BP_stats, [3, 2, 1, 4, 5]);
            
            BPs_dims = size(BP_stats_new);
            
            BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4), BPs_dims(5));
            
            All_BP_stats(:, ch, :, :, :, :) = BP_stats_new;
            
            load([ch_dir, '/', ch_dir, '_BP', ranksum_suffix, '.mat'])
            
            BP_ranksum_new = permute(BP_ranksum, [4, 2, 1, 3]);
            
            BPr_dims = size(BP_ranksum_new);
            
            BP_ranksum_new = reshape(BP_ranksum_new, BPr_dims(1), 1, BPr_dims(2), BPr_dims(3), BPr_dims(4));
            
            All_BP_ranksum(:, ch, :, :, :) = BP_ranksum_new;
            
        end
        
        All_BP_test = All_BP_ranksum <= .01/(3*sum(sum(sum(sum(sum(~isnan(All_BP_ranksum)))))));
        
        no_bands = length(band_labels);
        
        tick_spacing = floor(length(cat2_labels)/3);
        
        for d = 2:no_drugs
            
            for b = 1:no_bands
                
                for state = 1:no_states
                    
                    clear plot_stats plot_test
                    
                    for s = 1:2
                        
                        plot_stats(:, :, s) = [All_BP_stats(:, :, state, b, stat_indices(s), 1) All_BP_stats(:, :, state, b, stat_indices(s), d)];
                    
                        plot_test(:, :, s) = [nan(size(All_BP_test(:, :, state, b, d - 1))) All_BP_test(:, :, state, b, d - 1)];
                        
                    end
                    
                    plot_test(plot_test == 0) = nan; plot_test(:, :, 2) = nan;
                    
                    plot_stats = plot_stats(:, [1 4 2 5 3 6], :); % Interleaving saline & drug data series, for purposes of custom linestyle cycling.
                    
                    plot_test = plot_test(:, [1 4 2 5 3 6], :);
                    
                    med_min = min(min(plot_stats(:, :, 1)));
                    
                    med_range = max(max(plot_stats(:, :, 1))) - med_min;
                    
                    test_multiplier = ones(size(plot_test(:, :, 1)))*diag(med_min - 2*[.05 .05 .1 .1 .15 .15]*med_range);
                    
                    for s = 1:2
                        
                        figure(2*d - 2 - (2 - s))
                        
                        subplot(no_states, no_bands, (state - 1)*no_bands + b)
                        
                        set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'s-','o-','^-'}, 'ColorOrder', c_order([1 d], :))
                        
                        % bounds = prep_for_boundedline(plot_stats(:, :, 1) - plot_stats(:, :, 2), plot_stats(:, :, 3) - plot_stats(:, :, 1));
                        %
                        % boundedline((1:length(cat2_labels))', plot_stats(:, :, 1), bounds, 'cmap', c_order([1 d], :))
                        
                        plot((1:length(cat2_labels))', [plot_stats(:, :, s) plot_test(:, :, s).*test_multiplier])
                        
                        title(band_labels{b})
                        
                        tit_le = {[drugs{d}, ', ', state_labels{state}];[stat_labels{s}, ' Band Pow.', long_norms{n}]};
                        
                        if b == 1
                            
                            ylabel(tit_le)
                            
                            if state == 1
                                
                                legend({'Front., sal.', ['Front., ', drugs{d}], 'Occi., sal.', ['Occi., ', drugs{d}], 'CA1, sal.', ['CA1, ', drugs{d}]})
                                
                            end
                            
                        end
                        
                        set(gca, 'XTick', 1:tick_spacing:length(cat2_labels), 'XTickLabel', cat2_labels(1:tick_spacing:end))
                        
                        if s == 1
                            
                            ylim([med_min - .4*med_range, med_min + 1.1*med_range]) 
                            
                        else
                            
                            axis tight
                            
                        end
                        
                        xlabel(['Time Rel. Inj. (', periods{p}, ')'])
                        
                    end
                    
                end
                
            end
            
            save_as_pdf(2*d - 1 - 2, ['ALL_BP', suffix, '_', drugs{d}, '_median'])
            
            save_as_pdf(2*d - 2, ['ALL_BP', suffix, '_', drugs{d}, '_mean'])
            
        end
            
        close('all')
        
    end
    
end

for n = 1:no_norms
    
    for p = 1:no_pds
        
        suffix = [norms{n}, periods{p}, '_', mat_labels{1}];
        
        for d = 2:no_drugs
            
            open(['ALL_BP', suffix, '_', drugs{d}, '_median.fig'])
            
        end
        
        for d = 2:no_drugs
            
            open(['ALL_BP', suffix, '_', drugs{d}, '_mean.fig'])
            
        end
        
    end
    
end

end
