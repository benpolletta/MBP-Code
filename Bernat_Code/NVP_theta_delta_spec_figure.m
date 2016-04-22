function NVP_theta_delta_spec_figure%(hour_lims,freq_lims,no_hr_ticks,no_freq_ticks,clims)

% SAMPLE CALL: plot_spec_horiz_all_channels([-120 360], [0 200], 8, 6, 'rows')

% freq_label = sprintf('%g-%g',freq_lims(1),freq_lims(2));

freqs = 500*(1:2^9)/(2^10); freqs = freqs(freqs <= 200);

bands = [1 12; 20 200]; no_bands = size(bands, 1);

[band_indices, long_band_names] = deal(cell(no_bands, 1));

for b = 1:no_bands
    
    band_indices{b} = freqs >= bands(b, 1) & freqs <= bands(b,2);
    long_band_names{b} = sprintf('%d to %d Hz', bands(b, 1), bands(b, 2));

end

load('channels.mat'), 

channels_selected = [1 3]; no_channels = length(channels_selected);

load('drugs.mat')

%for i=1:no_channels, xlabels{i}='Time Since Injection (h)'; ylabels{i}={channel_names{i};'Frequency (Hz)'}; end

stats={'median','mean','std'}; no_stats = length(stats);
long_stats={'Median','Mean','St. Dev.'};

norms={'pct_'}; %,'zs_'}; 
no_norms = length(norms);
long_norms={'% Change'}; %, 'z-Scored'};

no_pre=0; no_post=4;
[sixmin_labels, ~]=make_period_labels(no_pre,no_post,'6mins');
no_6min_periods = length(sixmin_labels);
short_6min_labels = (1:40)*6 - 3;

no_pre=0; no_post=4;
[hr_labels, ~, long_hr_labels]=make_period_labels(no_pre,no_post,'6mins');
no_hr_periods = length(hr_labels);

no_pre=0; no_post=4;
[BP_6min_labels, ~, long_BP_6min_labels]=make_period_labels(no_pre,no_post,'6mins');
no_BP_6min_periods = length(BP_6min_labels);
short_BP_6min_labels = (1:40)*6 - 3; short_BP_6min_labels(short_BP_6min_labels == 0) = [];

tick_spacing = floor(no_BP_6min_periods/5);

no_BP_bands = 8;

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels

%for i=1:3, xlabels{i}='Time Since Injection (h)'; ylabels{i}=; end
           
All_cplot_data = nan(length(freqs), no_drugs, no_6min_periods, no_stats, no_channels, no_norms);

All_BP_stats = nan(no_BP_6min_periods, no_channels, no_BP_bands, no_stats, no_drugs, no_norms);

[All_BP_ranksum, All_BP_test] = deal(nan(no_BP_6min_periods, no_channels, no_BP_bands, no_drugs - 1, no_norms));
    
for n=1:no_norms
    
    for c=1:no_channels
        
        channel_name = channel_names{channels_selected(c)};
        
        ch_dir = ['ALL_', channel_name];
        
        %% Getting colorplot data.
        
        % titles{c}=[long_stats{s},' ',channels{c},' Power, ',long_norms{n},' ',drugs{d}];
        
        load(['ALL_',channel_name,'/ALL_',channel_name,'_spec_',norms{n},'6mins_spec_stats_for_cplot.mat'])
        
        pd_index = (str2double(cat2_labels) >= min(short_6min_labels) & str2double(cat2_labels) <= max(short_6min_labels));
        
        All_cplot_data(:, :, :, :, c, n) = spec_stats(:, :, pd_index, :);
        
        %% Getting time series data.
        
        suffix = ['_BP_', norms{n}, '6min_BP_stats'];
        
        ranksum_suffix = ['_BP_', norms{n}, '6min_ranksum'];
            
        load([ch_dir, '/', ch_dir, suffix, '.mat'])
        
        pd_index = (str2double(cat2_labels) >= min(short_6min_labels) & str2double(cat2_labels) <= max(short_6min_labels));
        
        BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        BPs_dims = size(BP_stats_new);
        
        BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
        
        All_BP_stats(:, c, :, :, :, n) = BP_stats_new(pd_index, :, :, [1 4 5], :);
        
        load([ch_dir, '/', ch_dir, ranksum_suffix, '.mat'])
        
        pd_index = (str2double(cat2_labels) >= min(short_6min_labels) & str2double(cat2_labels) <= max(short_6min_labels));
        
        BP_ranksum_new = permute(BP_ranksum, [2, 1, 3]);
        
        BPr_dims = size(BP_ranksum_new);
        
        BP_ranksum_new = reshape(BP_ranksum_new, BPr_dims(1), 1, BPr_dims(2), BPr_dims(3));
        
        All_BP_ranksum(:, c, :, :, n) = BP_ranksum_new(pd_index, :, :, :);
        
    end
    
    All_BP_test(:, :, :, :, n) = All_BP_ranksum(:, :, :, :, n) <= .01/(3*sum_all_dimensions(~isnan(All_BP_ranksum(:, :, :, :, n))));
    
end

handle = nan(no_drugs, no_norms, no_stats);

for n = 1 % 1:no_norms
    
    for s = 1 % :no_stats
        
        for d = 3 % 1:no_drugs
            
            handle(d, n, s) = figure;
            
            %% Plotting spectra by channel.
            
            for c = 1:no_channels
                
                for b = 1 % :no_bands
                    
                    subplot(no_channels + 2, 1, c)
                    
                    imagesc(str2num(char(sixmin_labels))/60, freqs(band_indices{b}),...
                        reshape(All_cplot_data(band_indices{b}, d, :, s, c, n), sum(band_indices{b}), no_6min_periods))
                    
                    axis xy
                    
                    ylabel({channel_name}) % ;'Freq. (Hz)'})
                    
                    if c == 1
                        
                        title({[drugs{d}, ', ', long_band_names{b}];[long_stats{s}, ' Power, ', long_norms{n}]})
                        
                    elseif c == 3
                        
                        xlabel('Time Rel. Inj. (h)')
                        
                    end
                    
                end
                
            end
            
            %% Plotting time series w/ stats.
            
            colormap = [1 .5 0; 1 0 1];
            
            clear plot_stats plot_test
            
            plot_mean = [All_BP_stats(:, 1, 1, 2, d, n) All_BP_stats(:, 2, 2, 2, d, n)];
            
            plot_se = [All_BP_stats(:, 1, 1, 3, d, n) All_BP_stats(:, 2, 2, 3, d, n)];
            
            subplot(no_channels + 2, 1, no_channels + 1)
            
            boundedline(short_BP_6min_labels'/60, plot_mean, prep_for_boundedline(plot_se), 'cmap', colormap)
            
            % set(gca, 'XTick', 1:tick_spacing:no_BP_6min_periods, 'XTickLabel', short_BP_6min_labels(1:tick_spacing:no_BP_6min_periods))
            
            axis tight
            
            legend({'Fr. 1 - 5 Hz', 'CA1 5 - 11 Hz'})
            
            % title(band_labels{BP_band_indices(b)})
            
            xlabel('Time Rel. Inj. (h)')
            
            colormap = [1 .5 .5; 0 1 .5];
            
            clear plot_stats plot_test
            
            plot_mean = [All_BP_stats(:, 1, 2, 2, d, n) All_BP_stats(:, 2, 1, 2, d, n)];
            
            plot_se = [All_BP_stats(:, 1, 2, 3, d, n) All_BP_stats(:, 2, 1, 3, d, n)];
            
            subplot(no_channels + 2, 1, no_channels + 2)
            
            boundedline(short_BP_6min_labels'/60, plot_mean, prep_for_boundedline(plot_se), 'cmap', colormap)
            
            % set(gca, 'XTick', 1:tick_spacing:no_BP_6min_periods, 'XTickLabel', short_BP_6min_labels(1:tick_spacing:no_BP_6min_periods))
            
            axis tight
            
            legend({'Fr. 5 - 11 Hz', 'CA1 1 - 5 Hz'})
            
            % title(band_labels{BP_band_indices(b)})
            
            xlabel('Time Rel. Inj. (h)')
            
            save_as_pdf(gcf,['ALL_',drugs{d},'_spec_',norms{n},'theta_delta_', stats{s}])
            
        end
        
    end
    
end
