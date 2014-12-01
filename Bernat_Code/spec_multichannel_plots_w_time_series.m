function spec_multichannel_plots_w_time_series%(hour_lims,freq_lims,no_hr_ticks,no_freq_ticks,clims)

% SAMPLE CALL: plot_spec_horiz_all_channels([-120 360], [0 200], 8, 6, 'rows')

%freq_label = sprintf('%g-%g',freq_lims(1),freq_lims(2));

freqs=500*(1:2^9)/(2^10); freqs=freqs(freqs<=200);

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat')

%for i=1:no_channels, xlabels{i}='Time Since Injection (h)'; ylabels{i}={channel_names{i};'Frequency (Hz)'}; end

stats={'median','mean','std'}; no_stats = length(stats);
long_stats={'Median','Mean','St. Dev.'};

norms={'pct_','zs_'}; no_norms = length(norms);
long_norms={'% Change', 'z-Scored'};

no_pre=4; no_post=12;
[sixmin_labels, ~]=make_period_labels(no_pre,no_post,'6mins');
no_6min_periods = length(sixmin_labels);

no_pre=4; no_post=12;
[hr_labels, ~, long_hr_labels]=make_period_labels(no_pre,no_post,'hrs');
no_hr_periods = length(hr_labels);

no_pre=4; no_post=16;
[BP_hr_labels, ~, long_BP_hr_labels]=make_period_labels(no_pre,no_post,'hrs');
no_BP_hr_periods = length(BP_hr_labels);
short_BP_hr_labels = -4:16; short_BP_hr_labels(short_BP_hr_labels == 0) = [];

tick_spacing = floor(no_BP_hr_periods/5);

no_bands = 8;

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels

%for i=1:3, xlabels{i}='Time Since Injection (h)'; ylabels{i}=; end
           
All_cplot_data = nan(length(freqs), no_drugs, no_6min_periods, no_stats, no_channels, no_norms);
           
All_lineplot_data = nan(length(freqs), no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

All_BP_stats = nan(no_BP_hr_periods, no_channels, no_bands, no_stats, no_drugs, no_norms);

[All_BP_ranksum, All_BP_test] = deal(nan(no_BP_hr_periods, no_channels, no_bands, no_drugs - 1, no_norms));
    
for n=1:no_norms
    
    for c=1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];
        
        %% Getting colorplot data.
        
        % titles{c}=[long_stats{s},' ',channels{c},' Power, ',long_norms{n},' ',drugs{d}];
        
        load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_spec_',norms{n},'6mins_spec_stats_for_cplot.mat'])
        
        All_cplot_data(:, :, :, :, c, n) = spec_stats;
        
        load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_spec_',norms{n},'hrs_spec_stats_for_cplot.mat'])
        
        All_lineplot_data(:, :, :, :, c, n) = spec_stats;
        
        %% Getting time series data.
        
        suffix = ['_BP_', norms{n}, 'hrs_BP_stats'];
        
        ranksum_suffix = ['_BP_', norms{n}, 'hrs_ranksum'];
            
        load([ch_dir, '/', ch_dir, suffix, '.mat'])
        
        BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        BPs_dims = size(BP_stats_new);
        
        BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
        
        All_BP_stats(:, c, :, :, :, n) = BP_stats_new(1:no_BP_hr_periods, :, :, [1 4 5], :);
        
        load([ch_dir, '/', ch_dir, ranksum_suffix, '.mat'])
        
        BP_ranksum_new = permute(BP_ranksum, [2, 1, 3]);
        
        BPr_dims = size(BP_ranksum_new);
        
        BP_ranksum_new = reshape(BP_ranksum_new, BPr_dims(1), 1, BPr_dims(2), BPr_dims(3));
        
        All_BP_ranksum(:, c, :, :, n) = BP_ranksum_new(1:no_BP_hr_periods, :, :, :);
        
    end
    
    All_BP_test(:, :, :, :, n) = All_BP_ranksum(:, :, :, :, n) <= .01/(3*sum_all_dimensions(~isnan(All_BP_ranksum(:, :, :, :, n))));
    
end

handle = nan(no_drugs, no_norms, no_stats);

for n = 1:no_norms
    
    for s = 1:no_stats
        
        for d = 1:no_drugs
            
            handle(d, n, s) = figure;
            
            %% Plotting spectra by channel.
            
            for c = 1:no_channels
                
                subplot(no_channels + 1 + (d > 1), 1, c)
                
                imagesc(str2num(char(sixmin_labels)), freqs, reshape(All_cplot_data(:, d, :, s, c, n), length(freqs), no_6min_periods))
                
                axis xy
                
                ylabel({channel_names{c}}) % ;'Freq. (Hz)'})
                
                if c == 1
                    
                    title({[drugs{d}, ', ', long_stats{s}, ' Power, ', long_norms{n}]})
                    
                elseif c == 3
                    
                    xlabel('Time Rel. Inj. (m)')
                    
                end
                
            end
            
            %% Plotting profiles of spectra.
            
            for h = 5:9
                
                subplot(no_channels + 1 + (d > 1), 5, no_channels*5 + h - 4)
            
                plot(freqs', reshape(All_lineplot_data(:, d, h, s, :, n), length(freqs), no_channels))
                
                title(long_hr_labels{h})
                
                xlabel('Freq. (Hz)')
                
                if h == 5
                    
                    legend(channel_names, 'Location', 'SouthEast', 'FontSize', 6)
                    
                    ylabel({[long_stats{s}, ' Power']; long_norms{n}})
                    
                end
                
            end
            
            %% Plotting time series w/ stats.
            
            if d > 1
                
                band_indices = [1 2 5:no_bands]; no_bands_plotted = length(band_indices);
                
                for b = 1:no_bands_plotted
                    
                    clear plot_stats plot_test
                    
                    plot_stats = [All_BP_stats(:, :, band_indices(b), 1, 1, n) All_BP_stats(:, :, band_indices(b), 1, d, n)];
                        
                    plot_test(:, :) = [nan(size(All_BP_test(:, :, band_indices(b), d - 1, n))) All_BP_test(:, :, band_indices(b), d - 1, n)];
                    
                    plot_test(plot_test == 0) = nan;
                        
                    % plot_stats = plot_stats(:, [1 4 2 5 3 6]); % Interleaving saline & drug data series, for purposes of custom linestyle cycling.
                    % 
                    % plot_test = plot_test(:, [1 4 2 5 3 6]);
                        
                    med_min = min(min(plot_stats(:, :, 1)));
                    
                    med_range = max(max(plot_stats(:, :, 1))) - med_min;
                    
                    test_multiplier = ones(size(plot_test))*diag(med_min - [nan nan nan 0.05 .1 .15]*med_range);
                    
                    subplot(no_channels + 1 + (d > 1), no_bands_plotted, (no_channels + 1)*no_bands_plotted + b)
                    
                    set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'--','-','*','*'}, 'ColorOrder', c_order)
                    
                    plot((1:no_BP_hr_periods)', [plot_stats plot_test.*test_multiplier])
                    
                    if b == 1
                    
                        legend({'Front., sal.', 'Occi., sal.', 'CA1, sal.', ['Front., ', drugs{d}], ['Occi., ', drugs{d}], ['CA1, ', drugs{d}]},...
                            'Location', 'NorthWest', 'FontSize', 6)
                    
                    end
                        
                    set(gca, 'XTick', 1:tick_spacing:no_BP_hr_periods, 'XTickLabel', short_BP_hr_labels(1:tick_spacing:no_BP_hr_periods))
                    
                    axis tight
                    
                    ylim([med_min - .2*med_range, med_min + 1.05*med_range])
                    
                    title(band_labels{band_indices(b)})
                    
                    xlabel('Time Rel. Inj. (h)')
                    
                end
                
            end
                
            save_as_pdf(gcf,['ALL_',drugs{d},'_spec_',norms{n},'_multichannel_', stats{s}])
            
        end
        
        close('all')
        
    end
    
end
    
for n=1:no_norms
    
    for s=1:no_stats
        
        for d=1:no_drugs
            
            open(['ALL_',drugs{d},'_spec_',norms{n},'_multichannel_', stats{s}, '.fig'])
        end
        
    end
    
end
