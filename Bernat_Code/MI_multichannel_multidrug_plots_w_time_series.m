function MI_multichannel_multidrug_plots_w_time_series

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat')

stats={'median','mean','std'}; no_stats = length(stats);
long_stats={'Median','Mean','St. Dev.'};

norms={'', '_pct'}; no_norms = length(norms);
long_norms={'', '% Change'};% From Baseline'};

no_pre=4; no_post=12;
[hr_labels, ~, long_hr_labels] = make_period_labels(no_pre, no_post, 'hrs');
no_hr_periods = length(hr_labels);

no_pre=4; no_post=16;
[BP_hr_labels, ~, ~] = make_period_labels(no_pre, no_post, 'hrs');
no_BP_hr_periods = length(BP_hr_labels);
short_BP_hr_labels = -4:12; short_BP_hr_labels(short_BP_hr_labels == 0) = [];

tick_spacing = floor(no_BP_hr_periods/5);

no_bands = 6;
            
bands_plotted = [2 5 6]; no_bands_plotted = length(bands_plotted);

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels

preinj_data = nan(no_afs, no_pfs, no_stats, no_channels, no_norms);
           
All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

All_BP_stats = nan(no_BP_hr_periods, no_channels, no_bands, no_stats, no_drugs, no_norms);

[All_BP_ranksum, All_BP_test] = deal(nan(no_BP_hr_periods, no_channels, no_bands, no_drugs - 1, no_norms));
    
for n=1:no_norms
    
    for c=1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];

        %% Getting preinjection data.
        
        if isempty([ch_dir, '/', ch_dir, '_p0.99_IEzs_hr_MI', norms{n}, '_preinjection'])
            
            hr_periods = text_read([ch_dir, '/', ch_dir, '_p0.99_IEzs_hr_periods.txt'],'%s');
            
            MI = load([ch_dir, '/', ch_dir, '_p0.99_IEzs_hr_MI', norms{n}, '.txt']);
            
            preinj_indices = strcmp(hr_periods, 'pre1') | strcmp(hr_periods, 'pre2');
            
            preinj_data(:, :, 1, c, n) = reshape(nanmedian(MI(preinj_indices, :)), no_afs, no_pfs);
            
            preinj_data(:, :, 2, c, n) = reshape(nanmean(MI(preinj_indices, :)), no_afs, no_pfs);
            
            save([ch_dir, '/', ch_dir, '_p0.99_IEzs_hr_MI', norms{n}, '_preinjection'], 'preinj_data')
            
        else
            
            load([ch_dir, '/', ch_dir, '_p0.99_IEzs_hr_MI', norms{n}, '_preinjection'])
            
        end
            
        %% Getting colorplot data.
        
        for d = 1:no_drugs
            
            load([ch_dir,'/',ch_dir,'_p0.99_IEzs_MI','/',...
                ch_dir,'_p0.99_IEzs_hr',norms{n},'_',drugs{d},'_cplot_data.mat'])
            
            All_cplot_data(:, :, d, :, :, c, n) = MI_stats(:, :, 1, :, :);
            
        end
        
        %% Getting time series data.
        
        suffix = ['hrMI', norms{n}, '_hr_BP_stats'];
        
        load([ch_dir, '/', ch_dir, '_summed_', suffix, '.mat'])
        
        BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        BPs_dims = size(BP_stats_new);
        
        BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
        
        All_BP_stats(:, c, :, :, :, n) = BP_stats_new(1:no_BP_hr_periods, :, :, [1 4 5], :);
        
        %% Getting stats p-values.
        
        ranksum_suffix = ['hrMI', norms{n}, '_hr_ranksum'];
        
        load([ch_dir, '/', ch_dir, '_summed_', ranksum_suffix, '.mat'])
        
        BP_ranksum_new = permute(BP_ranksum, [2, 1, 3]);
        
        BPr_dims = size(BP_ranksum_new);
        
        BP_ranksum_new = reshape(BP_ranksum_new, BPr_dims(1), 1, BPr_dims(2), BPr_dims(3));
        
        All_BP_ranksum(:, c, :, :, n) = BP_ranksum_new(1:no_BP_hr_periods, :, :, :);
        
    end
    
    % Bonferroni correcting & testing p-values.
    
    All_BP_test(:, :, :, :, n) = All_BP_ranksum(:, :, :, :, n) <= .01/(3*sum_all_dimensions(~isnan(All_BP_ranksum(:, :, :, :, n))));
    
end

[~, max_hr_indices] = max(max(max(All_cplot_data(:, :, :, 4:end, :, :, :))), [], 4);

max_hr_indices = reshape(max_hr_indices, no_drugs, no_stats, no_channels, no_norms);

handle = nan(no_drugs, no_norms, no_stats);

All_cplot_for_plot = nan(no_afs, no_pfs, no_drugs + 1, no_stats, no_channels, no_norms);

All_cplot_for_plot(:, :, 1, s, c, n) = permute(preinj_data(:, :, s, c, n), [1 2 6 3 4 5]);

for n = 1:no_norms
    
    for c = 1:no_channels
        
        for s = 1:no_stats
            
            % All_cplot_for_plot(:, :, 1, s, c, n) = preinj_data(:, :, s, c, n);
            
            for d = 1:no_drugs
                
                All_cplot_for_plot(:, :, d + 1, s, c, n) = All_cplot_data(:, :, d, max_hr_indices(d, s, c, n) + 4 - 1, s, c, n);
                
            end
            
        end
        
    end
    
end

max_by_drug = reshape(max(max(max(All_cplot_for_plot)), [], 5), no_drugs + 1, no_stats, no_norms);

min_by_drug = reshape(min(min(min(All_cplot_for_plot)), [], 5), no_drugs + 1, no_stats, no_norms);

for n = 1:no_norms
    
    for s = 1:no_stats
        
        handle(n, s) = figure;
        
        for c = 1:no_channels
            
            subplot(no_channels + no_bands_plotted, no_drugs + 1, (c - 1)*(no_drugs + 1) + 1)
            
            imagesc(phase_freqs, amp_freqs, All_cplot_for_plot(:, :, 1, s, c, n))
            
            caxis([min_by_drug(d, s, n) max_by_drug(d, s, n)])
            
            axis xy
            
            ylabel(channel_names(c))
            
            if c == 1
                
                title(['Preinjection, ', long_stats{s}, ' MI, ', long_norms{n}])
                
            end
            
            for d = 1:no_drugs
                
                %% Plotting comodulograms.
                
                subplot(no_channels + no_bands_plotted, no_drugs + 1, (c - 1)*(no_drugs + 1) + d + 1)
                
                imagesc(phase_freqs, amp_freqs, All_cplot_for_plot(:, :, d, s, c, n))
                
                caxis([min_by_drug(d, s, n) max_by_drug(d, s, n)])
                
                axis xy
                
                if c == 1
                    
                    title({[drugs{d}, ', ', long_stats{s}, ' MI, ', long_norms{n}]; long_hr_labels{max_hr_indices(d, s, c, n) + 4 - 1}})
                    
                else
                    
                    title(long_hr_labels{max_hr_indices(d, s, c, n) + 4 - 1})
                    
                end
            
                %% Plotting time series w/ stats.
                
                if d > 1
                    
                    for b = bands_plotted
                        
                        clear plot_stats plot_test
                        
                        plot_stats = [All_BP_stats(:, :, b, 1, 1) All_BP_stats(:, :, b, 1, d)];
                        
                        plot_test(:, :) = [nan(size(All_BP_test(:, :, b, d - 1))) All_BP_test(:, :, b, d - 1)];
                        
                        plot_test(plot_test == 0) = nan;
                        
                        med_min = min(min(plot_stats(:, :, 1)));
                        
                        med_range = max(max(plot_stats(:, :, 1))) - med_min;
                        
                        test_multiplier = ones(size(plot_test))*diag(med_min - [nan nan nan 0.05 .1 .15]*med_range);
                        
                        subplot(no_channels + no_bands_plotted, no_drugs - 1, no_channels + (b - 1)*(no_drugs - 1) + d - 1)
                        
                        set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'--','-','*','*'}, 'ColorOrder', c_order)
                        
                        plot((1:no_BP_hr_periods)', [plot_stats plot_test.*test_multiplier])
                        
                        if b == 1
                            
                            legend({'Fr., sal.', 'Occi., sal.', 'CA1, sal.', ['Fr., ', drugs{d}], ['Occi., ', drugs{d}], ['CA1, ', drugs{d}]},...
                                'Location', 'NorthWest', 'FontSize', 6)
                            
                        end
                        
                        set(gca, 'XTick', 1:tick_spacing:no_BP_hr_periods, 'XTickLabel', short_BP_hr_labels(1:tick_spacing:end))
                        
                        axis tight
                        
                        ylim([med_min - .2*med_range, med_min + 1.05*med_range])
                        
                        title([drugs{d}, ', ', band_labels{b}])
                        
                        xlabel('Time Rel. Inj. (h)')
                        
                    end
                    
                end
                
            end
            
        end
                
        save_as_pdf(gcf,['ALL_MI',norms{n},'_multichannel_multidrug_', stats{s}])
        
    end
    
end
    
for n=1:no_norms
    
    for s=1:no_stats
        
        for d=1:no_drugs
            
            open(['ALL_',drugs{d},'_MI',norms{n},'_multichannel_', stats{s}, '.fig'])
            
        end
        
    end
    
end

end

% function [max_phase, max_pd] = get_peak_periods
% 
% phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
% no_pfs = length(phase_freqs); no_afs = length(amp_freqs);
% 
% load('channels.mat'), no_channels = length(channel_names);
% 
% load('drugs.mat')
% 
% stats={'median','mean','std'}; no_stats = length(stats);
% 
% no_pre=4; no_post=12;
% [hr_labels, ~, ~]=make_period_labels(no_pre,no_post,'hrs');
% no_hr_periods = length(hr_labels);
% 
% All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_channels);
% 
% for c = 1:no_channels
%     
%     for d = 1:no_drugs
%         
%         load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_p0.99_IEzs_MI',...
%             '/ALL_',channel_names{c},'_p0.99_IEzs_hr_',drugs{d},'_cplot_data.mat'])
%         
%         All_cplot_data(:, :, d, :, c) = MI_stats(:, :, 1, :, 1);
%         
%     end
%     
% end
% 
% max_MI_data = reshape(max(max(All_cplot_data)), no_drugs, no_hr_periods, no_channels);
% 
% [~, max_pd_indices] = max(max_MI_data, [], 2);
% 
% max_pd = hr_labels(reshape(max_pd_indices, no_drugs, no_channels));
% 
% max_phase_data = reshape(max(All_cplot_data), no_pfs, no_drugs, no_hr_periods, no_channels);
%  
% [~, max_phase_indices] = max(max_phase_data);
% 
% max_phase = permute(phase_freqs(max_phase_indices), [2 1 3]);
% 
% end
