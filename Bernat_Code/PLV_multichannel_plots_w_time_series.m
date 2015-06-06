function PLV_multichannel_plots_w_time_series

freqs = [1:.25:12 20:5:200];

bands = [1 12; 20 200]; no_bands = size(bands, 1);

[band_indices, long_band_names] = deal(cell(no_bands, 1));

for b = 1:no_bands
    
    band_indices{b} = freqs >= bands(b, 1) & freqs <= bands(b,2);
    long_band_names{b} = sprintf('%d to %d Hz', bands(b, 1), bands(b, 2));

end
    
load('channels.mat')

short_channel_names = {'Fr.', 'Occi.', 'CA1'};

channel_pairs = nchoosek(1:3,2);
no_chan_pairs = size(channel_pairs,1);

[cp_labels, chanpair_labels, short_chanpair_labels] = deal(cell(no_chan_pairs, 1));

for cp = 1:no_chan_pairs
    
    cp_labels{cp} = [channel_names{channel_pairs(cp, 1)}, '_by_', channel_names{channel_pairs(cp, 2)}];
    
    chanpair_labels{cp} = [channel_names{channel_pairs(cp, 1)}, ' by ', channel_names{channel_pairs(cp, 2)}];
    
    short_chanpair_labels{cp} = [short_channel_names{channel_pairs(cp, 1)}, ' by ', short_channel_names{channel_pairs(cp, 2)}];
    
end
    
load('drugs.mat')

%for i=1:no_chan_pairs, xlabels{i}='Time Since Injection (h)'; ylabels{i}={channel_names{i};'Frequency (Hz)'}; end

stats={'median','mean','std'}; no_stats = length(stats);
long_stats={'Median','Mean','St. Dev.'};

norms={'pct_'};%,'zs_'}; 
no_norms = length(norms);
long_norms={'% Change','z-Scored'};

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

no_sub_bands = 6;

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels
           
All_cplot_data = nan(length(freqs), no_drugs, no_6min_periods, no_stats, no_chan_pairs, no_norms);
           
All_lineplot_data = nan(length(freqs), no_drugs, no_hr_periods, no_stats, no_chan_pairs, no_norms);

All_BP_stats = nan(no_BP_hr_periods, no_channels, no_sub_bands, no_stats, no_drugs, no_norms);

[All_BP_ranksum, All_BP_test] = deal(nan(no_BP_hr_periods, no_channels, no_sub_bands, no_drugs - 1, no_norms));
    
for n=1:no_norms
    
    for c=1:no_chan_pairs
        
        %% Getting colorplot data.
        
        load(['ALL_',cp_labels{c},'_PLV/ALL_',cp_labels{c},'_PLV_',norms{n},'6mins_spec_stats_for_cplot.mat'])
        
        display('size(All_cplot_data) = ')
        size(All_cplot_data(:,:,:,:,c,n))
        display('size(spec_stats) = ')
        size(spec_stats)
        
        All_cplot_data(:, :, :, :, c, n) = spec_stats;
        
        load(['ALL_',cp_labels{c},'_PLV/ALL_',cp_labels{c},'_PLV_',norms{n},'hrs_spec_stats_for_cplot.mat'])
        
        All_lineplot_data(:, :, :, :, c, n) = spec_stats;
        
        %% Getting time series data.
        
        suffix = ['_summed_PLV_', norms{n}, 'hr_BP_stats'];
        
        ranksum_suffix = ['_summed_PLV_', norms{n}, 'hr_ranksum'];
            
        load(['ALL_', cp_labels{c}, '_PLV/ALL_', cp_labels{c}, suffix, '.mat'])
        
        BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        BPs_dims = size(BP_stats_new);
        
        BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
        
        All_BP_stats(:, c, :, :, :, n) = BP_stats_new(1:no_BP_hr_periods, :, :, [1 4 5], :);
        
        load(['ALL_', cp_labels{c}, '_PLV/ALL_', cp_labels{c}, ranksum_suffix, '.mat'])
        
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
            
            %% Plotting PLV by channel pair.
            
            for c = 1:no_chan_pairs
                
                for b = 1:no_bands
                    
                    subplot(no_chan_pairs + 2 + (d > 1), 2, (c - 1)*2 + b)
                    
                    imagesc(str2num(char(sixmin_labels))/60, freqs(band_indices{b}),...
                        reshape(All_cplot_data(band_indices{b}, d, :, s, c, n), sum(band_indices{b}), no_6min_periods))
                    
                    axis xy
                    
                    if b == 1
                    
                        ylabel({short_chanpair_labels{c}}) %;'Freq. (Hz)'})
                    
                    end
                        
                    if c == 1
                        
                        title({[drugs{d}, ', ', long_band_names{b}]; [long_stats{s}, ' PLV, ', long_norms{n}]})
                        
                    elseif c == 3
                        
                        xlabel('Time Rel. Inj. (h)')
                        
                    end
                    
                end
                
            end
            
            %% Plotting profiles of PLV.
            
            for h = 5:9
                
                for b = 1:no_bands
                    
                    subplot(no_chan_pairs + 2 + (d > 1), 5, (no_chan_pairs + b -1)*5 + h - 4)
                    
                    plot(freqs(band_indices{b})', reshape(All_lineplot_data(band_indices{b}, d, h, s, :, n), sum(band_indices{b}), no_chan_pairs))
                    
                    if b == 1
                        
                        title(long_hr_labels{h})
                    
                    elseif b == 2
                    
                        xlabel('Freq. (Hz)')
                    
                    end
                        
                    axis tight
                    
                    if h == 5 && b == 1
                        
                        legend(short_chanpair_labels, 'Location', 'NorthWest', 'FontSize', 6)
                        
                        ylabel({[long_stats{s}, ' Power']; long_norms{n}})
                        
                    end
                    
                end
                
            end
            
            %% Plotting time series w/ stats.
            
            if d > 1
                
                for b = 1:no_sub_bands
                    
                    clear plot_stats plot_test
                    
                    plot_stats = [All_BP_stats(:, :, b, 1, 1, n) All_BP_stats(:, :, b, 1, d, n)];
                        
                    plot_test(:, :) = [nan(size(All_BP_test(:, :, b, d - 1, n))) All_BP_test(:, :, b, d - 1, n)];
                    
                    plot_test(plot_test == 0) = nan;
                        
                    % plot_stats = plot_stats(:, [1 4 2 5 3 6]); % Interleaving saline & drug data series, for purposes of custom linestyle cycling.
                    % 
                    % plot_test = plot_test(:, [1 4 2 5 3 6]);
                        
                    med_min = min(min(plot_stats(:, :, 1)));
                    
                    med_range = max(max(plot_stats(:, :, 1))) - med_min;
                    
                    test_multiplier = ones(size(plot_test))*diag(med_min - [nan nan nan 0.05 .1 .15]*med_range);
                    
                    subplot(no_channels + 2 + (d > 1), no_sub_bands, (no_channels + 2)*no_sub_bands + b)
                    
                    set(gca, 'NextPlot', 'add', 'LineStyleOrder', {'--','-','*','*'}, 'ColorOrder', c_order)
                    
                    plot((1:no_BP_hr_periods)', [plot_stats plot_test.*test_multiplier])
                    
                    if b == 1
                    
                        legend({'Fr. by Occi., sal.', 'Fr. by CA1, sal.', 'Occi. by CA1, sal.', ['Fr. by Occi., ', drugs{d}], ['Fr. by CA1, ', drugs{d}], ['Occi. by CA1, ', drugs{d}]},...
                            'Location', 'NorthWest', 'FontSize', 6)
                    
                    end
                        
                    set(gca, 'XTick', 1:tick_spacing:no_BP_hr_periods, 'XTickLabel', short_BP_hr_labels(1:tick_spacing:no_BP_hr_periods))
                    
                    axis tight
                    
                    ylim([med_min - .2*med_range, med_min + 1.05*med_range])
                    
                    title(band_labels{b})
                    
                    xlabel('Time Rel. Inj. (h)')
                    
                end
                
            end
                
            save_as_pdf(gcf,['ALL_',drugs{d},'_PLV_',norms{n},'_multichannel_', stats{s}])
            
        end
        
        close('all')
        
    end
    
end
    
for n=1:no_norms
    
    for s=1:no_stats
        
        for d=1:no_drugs
            
            open(['ALL_',drugs{d},'_PLV_',norms{n},'_multichannel_', stats{s}, '.fig'])
        end
        
    end
    
end
