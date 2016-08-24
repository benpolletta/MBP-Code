function summed_MI_MK801_NVP_figure % (hi_hr, cplot_norm)

hi_hr = 'drug'; cplot_norm = '';

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat')

stats={'median'}; %,'mean','std'}; 
no_stats = length(stats);
long_stats={'Median'}; % ,'Mean','St. Dev.'};

norms={''}; % , '_pct'}; 
no_norms = length(norms);
long_norms={''}; % , '% Change'};% From Baseline'};

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

drug_p_val_index = [1 4 2 3];

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels

preinj_data = nan(no_afs, no_pfs, no_stats, no_channels, no_norms);
           
All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

All_BP_stats = nan(no_BP_hr_periods, no_channels, no_bands, no_stats, no_drugs, no_norms);

[All_BP_ranksum, All_BP_test] = deal(nan(no_BP_hr_periods, no_channels, no_bands, no_drugs - 1, no_norms));
    
for n=1:no_norms
    
    for c=1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];
            
        %% Getting colorplot data.
        
        for d = 1:(no_drugs - 1)
            
            load([ch_dir,'/',ch_dir,'_p0.99_IEzs_MI','/',...
                ch_dir,'_p0.99_IEzs_hrMI_hr',norms{n},'_',drugs{d},'_cplot_data.mat'])
            
            All_cplot_data(:, :, d, :, :, c, n) = MI_stats(:, :, 1, :, 1);
            
        end
        
        %% Getting time series data.
        
        suffix = ['hrMI', norms{n}, '_hr_BP_stats'];
        
        load([ch_dir, '/', ch_dir, '_summed_', suffix, '.mat'])
        
        BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        BPs_dims = size(BP_stats_new);
        
        BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
        
        All_BP_stats(:, c, :, :, :, n) = BP_stats_new(1:no_BP_hr_periods, :, :, 1, :); % [1 4 5] are where the median, mean, and std are.
        
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

for n = 1:no_norms
    
    for s = 1:no_stats
        
        handle(n, s) = figure;
        
        for c = 1:no_channels
            
        %% Plotting time series w/ stats.
        
        for d = 2:(no_drugs - 1)
            
            for b = 1:no_bands_plotted
                
                clear plot_stats plot_test
                
                plot_stats = [All_BP_stats(:, :, bands_plotted(b), s, 1) All_BP_stats(:, :, bands_plotted(b), s, d)];
                
                plot_test(:, :) = [nan(size(All_BP_test(:, :, bands_plotted(b), d - 1)))... % drug_p_val_index(d) - 1)))...
                    All_BP_test(:, :, bands_plotted(b), d - 1)]; % drug_p_val_index(d) - 1)];
                
                plot_test(plot_test == 0) = nan;
                
                med_min = min(min(plot_stats(:, :, 1)));
                
                med_range = max(max(plot_stats(:, :, 1))) - med_min;
                
                test_multiplier = ones(size(plot_test))*diag(med_min - [nan nan nan 0.05 .1 .15]*med_range);
                
                subplot(no_drugs - 2, no_bands_plotted, (d - 2)*no_bands_plotted + b)
                
                set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'--','-','*','*'}, 'ColorOrder', c_order)
                
                plot((1:no_BP_hr_periods)', [plot_stats plot_test.*test_multiplier])
                
                set(gca, 'XTick', 1:tick_spacing:no_BP_hr_periods, 'XTickLabel', short_BP_hr_labels(1:tick_spacing:end), 'FontSize', 16)
                
                axis tight
                
                ylim([med_min - .2*med_range, med_min + 1.05*med_range])
                
                if b == 1
                    
                    ylabel(drugs{d})
                    
                    if d - 1 == 1
                        
                        legend({'Fr., sal.', 'Occi., sal.', 'CA1, sal.', 'Fr., drug', 'Occi., drug', 'CA1, drug'},...
                            'Location', 'NorthEast', 'FontSize', 6)
                        
                    end
                    
                end
                
                if d - 1 == 1
                    
                    title(band_labels{bands_plotted(b)})
                    
                elseif d - 1 == 2
                    
                    xlabel('Time Rel. Inj. (h)')
                    
                end
                
            end
            
        end
                
        save_as_pdf(gcf,['ALL_summed_MI',norms{n},'_multichannel_MK801_NVP_', hi_hr, '_hi_', stats{s}, cplot_norm]) %, 'orientation', 'portrait')
        
    end
    
end

end
