function MI_multichannel_plots_w_time_series

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), no_channels = length(channel_names);

short_channel_names = {'Fr.', 'Occi.', 'CA1'};

load('drugs.mat')

stats={'median','mean','std'}; no_stats = length(stats);
long_stats={'Median','Mean','St. Dev.'};

norms={'', 'pct_'}; no_norms = length(norms);
long_norms={'', 'Pct. Change From Baseline'};

no_pre=4; no_post=12;
[hr_labels, ~, long_hr_labels]=make_period_labels(no_pre,no_post,'hrs');
no_hr_periods = length(hr_labels);

no_pre=4; no_post=16;
[BP_hr_labels, ~, long_BP_hr_labels]=make_period_labels(no_pre,no_post,'hrs');
no_BP_hr_periods = length(BP_hr_labels);

tick_spacing = floor(no_BP_hr_periods/4);

no_bands = 6;

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels
           
All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

All_BP_stats = nan(no_BP_hr_periods, no_channels, no_bands, no_stats, no_drugs, no_norms);

[All_BP_ranksum, All_BP_test] = deal(nan(no_BP_hr_periods, no_channels, no_bands, no_drugs - 1, no_norms));
    
for n=1:no_norms
    
    for c=1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];
            
        %% Getting colorplot data.
        
        for d = 1:no_drugs
            
            load([ch_dir,'/',ch_dir,'_p0.99_IEzs_MI','/',...
                ch_dir,'_p0.99_IEzs_hr_',norms{n},drugs{d},'_cplot_data.mat'])
            
            All_cplot_data(:, :, d, :, :, c, n) = MI_stats(:, :, 1, :, :);
            
        end
        
        %% Getting time series data.
        
        suffix = ['hrMI_', norms{n}, 'hr_BP_stats'];
        
        ranksum_suffix = ['hrMI_', norms{n}, 'hr_ranksum'];
        
        load([ch_dir, '/', ch_dir, '_summed_', suffix, '.mat'])
        
        BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        BPs_dims = size(BP_stats_new);
        
        BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
        
        All_BP_stats(:, c, :, :, :, n) = BP_stats_new(1:no_BP_hr_periods, :, :, [1 4 5], :);
        
        load([ch_dir, '/', ch_dir, '_summed_', ranksum_suffix, '.mat'])
        
        BP_ranksum_new = permute(BP_ranksum, [2, 1, 3]);
        
        BPr_dims = size(BP_ranksum_new);
        
        BP_ranksum_new = reshape(BP_ranksum_new, BPr_dims(1), 1, BPr_dims(2), BPr_dims(3));
        
        All_BP_ranksum(:, c, :, :, n) = BP_ranksum_new(1:no_BP_hr_periods, :, :, :);
        
    end
    
    All_BP_test(:, :, :, :, n) = All_BP_ranksum(:, :, :, :, n) <= .01/(3*sum_all_dimensions(~isnan(All_BP_ranksum(:, :, :, :, n))));
    
end

max_by_drug = reshape(max(max(max(All_cplot_data)), [], 4), no_drugs, no_stats, no_channels, no_norms);

min_by_drug = reshape(min(min(min(All_cplot_data)), [], 4), no_drugs, no_stats, no_channels, no_norms);

max_amp_data = reshape(max(All_cplot_data, [], 2), no_afs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

max_phase_data = reshape(max(All_cplot_data), no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

handle = nan(no_drugs, no_norms, no_stats);

for n = 1:no_norms
    
    for s = 1:no_stats
        
        for d = 1:no_drugs
            
            handle(d, n, s) = figure;
            
            %% Plotting comodulograms.
                
            no_hours = 8;
            
            for c = 1:no_channels
                
                for h = 2 + (1:no_hours);
                    
                    subplot(no_channels + 2 + (d > 1), no_hours, (c - 1)*no_hours + h - 2)
                    
                    imagesc(phase_freqs, amp_freqs, All_cplot_data(:, :, d, h, s, c, n))
                    
                    caxis([min_by_drug(d,s,c,n) max_by_drug(d, s, c, n)])
                    
                    % if h == 10
                    % 
                    %     colorbar
                    % 
                    % end
                    
                    axis xy
                    
                    ylabel({channel_names{c};'Amp. Freq. (Hz)'})
                    
                    if c == 1
                        
                        if h == 3
                            
                            title({drugs{d}; [long_stats{s}, ' MI, ', long_norms{n}]; long_hr_labels{h}})
                            
                        else
                            
                            title(long_hr_labels{h})
                            
                        end
                        
                    elseif c == 3
                        
                        xlabel('Phase Freq. (Hz)')
                        
                    end
                    
                end
                
            end
            
            %% Plotting comodulogram profiles.
            
            no_hours = 5;
            
            for h = (1:no_hours) + 4
                
                subplot(no_channels + 2 + (d > 1), no_hours, no_channels*no_hours + h - 4)
            
                plot(amp_freqs', reshape(max_amp_data(:, d, h, s, :, n), no_afs, no_channels))
                
                title(long_hr_labels{h})
                
                axis tight
                
                yl = ylim;
                
                ylim([yl(1) max(max_by_drug(d, s, :, n), [], 3)])
                
                xlabel('Amp. Freq. (Hz)')
                
                if h == 5
                    
                    legend(short_channel_names, 'Location', 'NorthWest')
                    
                    ylabel({['Max. ', long_stats{s}, ' MI']; long_norms{n}})
                    
                end
                
                subplot(no_channels + 2 + (d > 1), no_hours, (no_channels + 1)*no_hours + h - 4)
            
                plot(phase_freqs', reshape(max_phase_data(:, d, h, s, :, n), no_pfs, no_channels))
                
                axis tight
                
                yl = ylim;
                
                ylim([yl(1) max(max_by_drug(d, s, :, n), [], 3)])
                
                xlabel('Phase Freq. (Hz)')
                
                if h == 5
                    
                    ylabel({['Max. ', long_stats{s}, ' MI']; long_norms{n}})
                    
                end
                
            end
            
            %% Plotting time series w/ stats.
            
            if d > 1
                
                for b = 1:no_bands
                    
                    clear plot_stats plot_test
                    
                    plot_stats = nan(size(All_BP_stats, 1), 2*size(All_BP_stats, 2));
                    
                    plot_stats = [All_BP_stats(:, :, b, 1, 1) All_BP_stats(:, :, b, 1, d)];
                        
                    plot_test(:, :) = [nan(size(All_BP_test(:, :, b, d - 1))) All_BP_test(:, :, b, d - 1)];
                    
                    plot_test(plot_test == 0) = nan;
                        
                    % plot_stats = plot_stats(:, [1 4 2 5 3 6]); % Interleaving saline & drug data series, for purposes of custom linestyle cycling.
                    % 
                    % plot_test = plot_test(:, [1 4 2 5 3 6]);
                        
                    med_min = min(min(plot_stats(:, :, 1)));
                    
                    med_range = max(max(plot_stats(:, :, 1))) - med_min;
                    
                    test_multiplier = ones(size(plot_test))*diag(med_min - [.05 .05 .1 .1 .15 .15]*med_range);
                    
                    subplot(no_channels + 2 + (d > 1), no_bands, (no_channels + 2)*no_bands + b)
                    
                    set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'--','-','*','*'}, 'ColorOrder', c_order)
                    
                    plot((1:no_BP_hr_periods)', [plot_stats plot_test.*test_multiplier])
                    
                    if b == 1
                    
                        legend({'Front., sal.', 'Occi., sal.', 'CA1, sal.', ['Front., ', drugs{d}], ['Occi., ', drugs{d}], ['CA1, ', drugs{d}]},...
                            'Location', 'NorthWest')
                    
                    end
                        
                    set(gca, 'XTick', 1:tick_spacing:no_BP_hr_periods, 'XTickLabel', BP_hr_labels(1:tick_spacing:end))
                    
                    axis tight
                    
                    ylim([med_min - .2*med_range, med_min + 1.05*med_range])
                    
                    title(band_labels{b})
                    
                    xlabel('Time Rel. Injection (Hr.)')
                    
                end
                
            end
                
            save_as_pdf(gcf,['ALL_',drugs{d},'_MI_',norms{n},'_multichannel_', stats{s}])
            
        end
        
        close('all')
        
    end
    
end
    
for n=1:no_norms
    
    for s=1:no_stats
        
        for d=1:no_drugs
            
            open(['ALL_',drugs{d},'_MI_',norms{n},'_multichannel_', stats{s}, '.fig'])
            
        end
        
    end
    
end

end
