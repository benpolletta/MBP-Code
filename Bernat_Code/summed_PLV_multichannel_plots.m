function summed_PLV_multichannel_plots

c_order = [.5 .5 .5; 1 .75 0; 1 0 1; 0 1 1];

stat_labels={'median','Q1','Q3','mean','std'};
no_stats=length(stat_labels);

channel_pairs = nchoosek(1:3, 2); no_pairs = length(channel_pairs);

load('channels.mat')

load('drugs.mat'), no_drugs = length(drugs);

norms = {'_', '_pct_'}; no_norms = length(norms); long_norms = {'', ', Pct. of Baseline'};

periods = {'hr', '6min'}; no_pds = length(periods);

mat_labels = {'by_state', 'BP_stats'}; % no_mats = length(mat_labels);

%% Plots by time (not broken down by state).

for n = 1:no_norms
    
    for p = 1:no_pds
        
        suffix = [norms{n}, periods{p}, '_', mat_labels{2}];
            
        ranksum_suffix = [norms{n}, periods{p}, '_ranksum'];
        
        clear All_BP_stats All_BP_ranksum
        
        for pr = 1:no_pairs
            
            ch_dir = ['ALL_', channel_names{channel_pairs(pr, 1)}, '_by_', channel_names{channel_pairs(pr, 2)}, '_PLV'];
            
            load([ch_dir, '/', ch_dir(1 : end - 4), '_summed_PLV', suffix, '.mat'])
            
            BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
            
            BPs_dims = size(BP_stats_new);
            
            BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
            
            All_BP_stats(:, pr, :, :, :) = BP_stats_new;
            
            load([ch_dir, '/', ch_dir(1 : end - 4), '_summed_PLV', ranksum_suffix, '.mat'])
            
            BP_ranksum_new = permute(BP_ranksum, [2, 1, 3]);
            
            BPr_dims = size(BP_ranksum_new);
            
            BP_ranksum_new = reshape(BP_ranksum_new, BPr_dims(1), 1, BPr_dims(2), BPr_dims(3));
                
            All_BP_ranksum(:, pr, :, :) = BP_ranksum_new;
            
        end
            
        All_BP_test = All_BP_ranksum <= .01/(3*sum(sum(sum(sum(~isnan(All_BP_ranksum))))));
        
        no_bands = length(band_labels);
        
        [r, c] = subplot_size(no_bands);
        
        tick_spacing = floor(length(cat2_labels)/10);
        
        for d = 2:no_drugs
            
            for b = 1:no_bands
                
                clear plot_stats plot_test
                
                plot_stats = nan(size(All_BP_stats, 1), 2*size(All_BP_stats, 2), size(All_BP_stats, 3));
                
                for s = 1:no_stats
                    
                    plot_stats(:, :, s) = [All_BP_stats(:, :, b, s, 1) All_BP_stats(:, :, b, s, d)];
                    
                end
                
                plot_test(:, :) = [nan(size(All_BP_test(:, :, b, d - 1))) All_BP_test(:, :, b, d - 1)];
                
                plot_test(plot_test == 0) = nan;
                
                plot_stats = plot_stats(:, [1 4 2 5 3 6], :);
                
                plot_test = plot_test(:, [1 4 2 5 3 6]);
                
                med_min = min(min(plot_stats(:, :, 1)));
                
                med_range = max(max(plot_stats(:, :, 1))) - med_min;
                
                test_multiplier = ones(size(plot_test))*diag(med_min - [.05 .05 .1 .1 .15 .15]*med_range);
                
                figure(2*d - 1 - 2)
                
                subplot(r, c, b)
                
                set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'d-','*-','v-'}, 'ColorOrder', c_order([1 d], :))
                
                % bounds = prep_for_boundedline(plot_stats(:, :, 1) - plot_stats(:, :, 2), plot_stats(:, :, 3) - plot_stats(:, :, 1));
                %
                % boundedline((1:length(cat2_labels))', plot_stats(:, :, 1), bounds, 'cmap', c_order([1 d], :))
                
                plot((1:length(cat2_labels))', [plot_stats(:, :, 1) plot_test.*test_multiplier])
                
                if b == 1
                    
                    legend({'Fr. by Occi., sal.', ['Fr. by Occi., ', drugs{d}], 'Fr. by CA1, sal.', ['Fr. by CA1, ', drugs{d}],...
                        'Occi. by CA1, sal.', ['Occi. by CA1, ', drugs{d}]}, 'Location', 'Northwest')
                    
                end
                
                set(gca, 'XTick', 1:tick_spacing:length(cat2_labels), 'XTickLabel', cat2_labels(1:tick_spacing:end))
                    
                ylim([med_min - .2*med_range, med_min + 1.05*med_range]) %axis tight
                
                title({['PLV, Median for ', drugs{d}, long_norms{n}]; band_labels{b}})
                
                xlabel(['Time Rel. Injection (', periods{p}, ')'])
                
                figure(2*d - 2)
                
                subplot(r, c, b)
                
                set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'d-','*-','v-'}, 'ColorOrder', c_order([1 d], :))
                
                % bounds = prep_for_boundedline(plot_stats(:, :, 5));
                %
                % boundedline((1:length(cat2_labels))', plot_stats(:, :, 4), bounds, 'cmap', c_order([1 d], :))
                
                plot((1:length(cat2_labels))', plot_stats(:, :, 4))
                
                if b == 1
                    
                    legend({'Fr. by Occi., sal.', ['Fr. by Occi., ', drugs{d}], 'Fr. by CA1, sal.', ['Fr. by CA1, ', drugs{d}],...
                        'Occi. by CA1, sal.', ['Occi. by CA1, ', drugs{d}]})
                    
                end
                
                set(gca, 'XTick', 1:tick_spacing:length(cat2_labels), 'XTickLabel', cat2_labels(1:tick_spacing:end))
                
                axis tight
                
                title({['PLV, Mean for ', drugs{d}, long_norms{n}]; band_labels{b}})
                
                xlabel(['Time Rel. Injection (', periods{p}, ')'])
                
            end
            
            save_as_pdf(2*d - 1 - 2, ['ALL_summed_PLV', suffix, '_', drugs{d}, '_median'])
            
            save_as_pdf(2*d - 2, ['ALL_summed_PLV', suffix, '_', drugs{d}, '_mean'])
            
            close('all')
            
        end
        
    end
    
end

for n = 1:no_norms
    
    for p = 1:no_pds
        
        suffix = [norms{n}, periods{p}, '_', mat_labels{2}];
        
        for d = 2:no_drugs
            
            open(['ALL_summed_PLV', suffix, '_', drugs{d}, '_median.fig'])
            
        end
        
        for d = 2:no_drugs
            
            open(['ALL_summed_PLV', suffix, '_', drugs{d}, '_mean.fig'])
            
        end
        
    end
    
end

end
