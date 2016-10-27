function NVP_theta_delta_timecourse_figure

figure

bonferroni_count = 2*3*3*20 + 2*2*40 + 4;

freqs = 500*(1:2^9)/(2^10); freqs = freqs(freqs <= 200);

bands = [1 12; 20 200]; no_bands = size(bands, 1);

[band_indices, long_band_names] = deal(cell(no_bands, 1));

for b = 1:no_bands
    
    band_indices{b} = freqs >= bands(b, 1) & freqs <= bands(b,2);
    long_band_names{b} = sprintf('%d to %d Hz', bands(b, 1), bands(b, 2));

end

load('AP_freqs')

load('channels.mat')

channels_selected = [1 3]; no_channels_selected = length(channels_selected);

load('drugs.mat')

BP_stats={'median','mean','std'}; no_BP_stats = length(BP_stats);
long_BP_stats={'Median','Mean','St. Dev.'};

MI_stats={'median','Q1','Q2','mean','std'}; no_sMI_stats = length(MI_stats);
long_MI_stats={'Median','1st Quartile','2nd Quartile','Mean','St. Dev.'};

norms={'pct_'}; %,'zs_'}; 
no_norms = length(norms);
long_norms={'%\Delta'}; %, 'z-Scored'};

no_pre=0; no_post=4;
[sixmin_labels, ~]=make_period_labels(no_pre,no_post,'6mins');
no_6min_periods = length(sixmin_labels);
short_6min_labels = (1:40)*6 - 3;

no_pre=0; no_post=4;
[hr_labels, ~, long_hr_labels]=make_period_labels(no_pre,no_post,'hrs');
no_hr_periods = length(hr_labels);

no_pre=0; no_post=4;
[BP_6min_labels, ~, ~]=make_period_labels(no_pre,no_post,'6mins');
no_BP_6min_periods = length(BP_6min_labels);
short_BP_6min_labels = (1:40)*6 - 3; short_BP_6min_labels(short_BP_6min_labels == 0) = [];

no_BP_bands = 8; no_sMI_bands = 6;
    
clear titles xlabels ylabels
           
All_MI_cplot_data = nan(no_afs, no_pfs, no_hr_periods, no_channels);

All_sMI_stats = nan(no_BP_6min_periods, no_channels, no_sMI_bands, no_sMI_stats, no_drugs);
           
All_BP_cplot_data = nan(length(freqs), no_drugs, no_6min_periods, no_BP_stats, no_channels, no_norms);

All_BP_stats = nan(no_BP_6min_periods, no_channels, no_BP_bands, no_BP_stats, no_drugs, no_norms);
    
for n=1:no_norms
    
    for c=1:no_channels
        
        channel_name = channel_names{c};
        
        ch_dir = ['ALL_', channel_name];
        
        %% Getting MI colorplot data.
        
        load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_p0.99_IEzs_MI',...
            '/ALL_',channel_names{c},'_p0.99_IEzs_hrMI_hr_',drugs{3},'_cplot_data.mat'])
        
        pd_index = strcmp(cat2_labels, 'post1') | strcmp(cat2_labels, 'post2')...
            | strcmp(cat2_labels, 'post3') | strcmp(cat2_labels, 'post4');
        
        All_MI_cplot_data(:, :, :, c) = reshape(MI_stats(:, :, 1, pd_index, 1),...
            no_afs, no_pfs, no_hr_periods);
        
        %% Getting BP colorplot data.
        
        load(['ALL_',channel_name,'/ALL_',channel_name,'_spec_',norms{n},'6mins_spec_stats_for_cplot.mat'])
        
        pd_index = (str2double(cat2_labels) >= min(short_6min_labels) & str2double(cat2_labels) <= max(short_6min_labels));
        
        All_BP_cplot_data(:, :, :, :, c, n) = spec_stats(:, :, pd_index, :);
        
        %% Getting summed MI time series data.
        
        suffix = 'hrMI_6min_BP_stats';
        
        load([ch_dir, '/', ch_dir, '_summed_', suffix, '.mat'])
        
        pd_index = (str2double(cat2_labels) >= min(short_6min_labels) & str2double(cat2_labels) <= max(short_6min_labels));
        
        sMI_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        sMIs_dims = size(sMI_stats_new);
        
        sMI_stats_new = reshape(sMI_stats_new, sMIs_dims(1), 1, sMIs_dims(2), sMIs_dims(3), sMIs_dims(4));
        
        All_sMI_stats(:, c, :, :, :) = sMI_stats_new(pd_index, :, :, :, :);
        
        %% Getting BP time series data.
        
        suffix = ['_BP_', norms{n}, '6min_BP_stats'];
            
        load([ch_dir, '/', ch_dir, suffix, '.mat'])
        
        pd_index = (str2double(cat2_labels) >= min(short_6min_labels) & str2double(cat2_labels) <= max(short_6min_labels));
        
        BP_stats_new = permute(BP_stats, [2, 1, 3, 4]);
        
        BPs_dims = size(BP_stats_new);
        
        BP_stats_new = reshape(BP_stats_new, BPs_dims(1), 1, BPs_dims(2), BPs_dims(3), BPs_dims(4));
        
        All_BP_stats(:, c, :, :, :, n) = BP_stats_new(pd_index, :, :, [1 4 5], :);
        
    end
    
end

MI_min = reshape(min(min(min(All_MI_cplot_data))), no_channels, 1);

MI_max = reshape(max(max(max(All_MI_cplot_data))), no_channels, 1);

load('NVP_BP_theta_delta_stats.mat')

for n = 1 % 1:no_norms
    
    for d = 3 % 1:no_drugs
        
        %% Plotting MI by hour.
        
        for h = 1:4
            
            subplot(5, 4, h)
            
            imagesc(phase_freqs, amp_freqs, All_MI_cplot_data(:, :, h, 2))
            
            axis xy
            
            caxis([MI_min(2) MI_max(2)])
            
            if h == 1
 
                ylabel({['\fontsize{16}', channel_names{2}, ' MI']; ['\fontsize{14}(', long_MI_stats{1}, ')']; '\fontsize{12}Amp. Freq. (Hz)'})
                
            end
                
            title(long_hr_labels{h}, 'FontSize', 14)
            
            xlabel('Phase Freq. (Hz)', 'FontSize', 12)
            
        end
        
        %% Plotting summed MI time series.
        
        colormap = [1 .5 .5; 0 1 .5];
        
        subplot(5, 1, 2)
        
        set(gca, 'NextPlot', 'add', 'ColorOrder', colormap)
        
        [ax, h1, h2] = plotyy(short_BP_6min_labels'/60, All_sMI_stats(:, 2, end - 1, 1, d, n),...
            short_BP_6min_labels'/60, All_sMI_stats(:, 2, end, 1, d, n));
        
        % set(h1, 'colormap', colormap(1, :))
        
        legend([h1; h2], {'Occi. \delta-HFO PAC', 'Occi. \theta-HFO PAC'})
        
        axis(ax(1), 'tight'), axis(ax(2), 'tight')
        
        box off
        
        ylabel({'\fontsize{16}Occipital MI'; '\fontsize{14}(Median Sum)'}, 'Color', 'k')
        
        % plot_mean = All_sMI_stats(:, 2, end - 1, 1, d, n);
        %
        % plot_se = [plot_mean - All_sMI_stats(:, 2, end - 1, 2, d, n), All_sMI_stats(:, 2, end - 1, 3, d, n) - plot_mean];
        %
        % ax(1) = subplot(5, 1, 2);
        %
        % boundedline(short_BP_6min_labels'/60, plot_mean, plot_se, ax(1), 'cmap', colormap)
        %
        % axis(ax(1), 'tight')
        %
        % plot_mean = All_sMI_stats(:, 2, end, 1, d, n);
        %
        % plot_se = [plot_mean - All_sMI_stats(:, 2, end, 2, d, n), All_sMI_stats(:, 2, end, 3, d, n) - plot_mean];
        %
        % ax(2) = axes('position', get(ax(1), 'position'), 'Color', 'none', 'XTick', [], 'YAxisLocation', 'right');
        %
        % boundedline(short_BP_6min_labels'/60, plot_mean, plot_se, ax(2), 'cmap', colormap(2, :))
        %
        % axis(ax(2), 'tight')
        %
        % linkaxes(ax, 'x')
        
        % plot_mean = [All_sMI_stats(:, 2, end - 1, 1, d, n) All_sMI_stats(:, 2, end, 1, d, n)];
        %
        % % plot_mean = plot_mean - ones(size(plot_mean))*diag(mean(plot_mean));
        %
        % plot_se = [All_sMI_stats(:, 2, end - 1, 2, d, n) All_sMI_stats(:, 2, end, 2, d, n)];
        %
        % plot_se(:, :, 2) = [All_sMI_stats(:, 2, end - 1, 3, d, n) All_sMI_stats(:, 2, end, 3, d, n)];
        
        % boundedline(short_BP_6min_labels'/60, plot_mean, plot_se, 'cmap', colormap) % prep_for_boundedline(plot_se), 'cmap', colormap)
        
        % axis tight
        
        %% Plotting spectra by channel.
        
        for c = 1:no_channels_selected
            
            channel_name = channel_names{channels_selected(c)};
            
            for b = 1 % :no_bands
                
                subplot(5, 1, 2 + c)
                
                imagesc(str2num(char(sixmin_labels))/60, freqs(band_indices{b}),...
                    reshape(All_BP_cplot_data(band_indices{b}, d, :, 2, channels_selected(c), n),...
                    sum(band_indices{b}), no_6min_periods))
                
                axis xy
                
                ylabel({['\fontsize{16}', channel_name, ' Power']; ['\fontsize{14}(', long_BP_stats{2}, ' ', long_norms{n}, ')']})
                
            end
            
        end
        
        %% Plotting BP time series w/ stats.
        
        colormap = [1 .5 0; 1 0 1];
        
        clear plot_stats plot_test
        
        plot_mean = [All_BP_stats(:, 1, 1, 2, d, n) All_BP_stats(:, 3, 2, 2, d, n)];
        
        % plot_mean = plot_mean - ones(size(plot_mean))*diag(mean(plot_mean));
        
        plot_se = [All_BP_stats(:, 1, 1, 3, d, n) All_BP_stats(:, 3, 2, 3, d, n)];
        
        subplot(5, 1, 5)
        
        boundedline(short_BP_6min_labels'/60, plot_mean, prep_for_boundedline(plot_se), 'cmap', colormap)
        
        axis tight
        
        add_stars(gca, short_BP_6min_labels'/60, p_vals(:, :, 1) < .05/bonferroni_count, [1 1], colormap)
        
        legend({'Fr. 1 - 5 Hz', 'CA1 5 - 11 Hz'})
        
        % plot_mean = All_BP_stats(:, 1, 1, 2, d, n); plot_mean = [plot_mean nan(size(plot_mean))];
        %
        % % plot_mean = plot_mean - ones(size(plot_mean))*diag(mean(plot_mean));
        %
        % plot_se = All_BP_stats(:, 1, 1, 3, d, n); plot_se = [plot_se nan(size(plot_se))];
        %
        % ax(1) = subplot(5, 1, 5);
        %
        % boundedline(short_BP_6min_labels'/60, plot_mean, prep_for_boundedline(plot_se), ax(1), 'cmap', colormap)
        %
        % axis(ax(1), 'tight')
        %
        % plot_mean = All_BP_stats(:, 3, 2, 2, d, n); plot_se = All_BP_stats(:, 3, 2, 3, d, n);
        %
        % ax(2) = axes('position', get(ax(1), 'position'), 'Color', 'none', 'XTick', [], 'YAxisLocation', 'right');
        %
        % boundedline(short_BP_6min_labels'/60, plot_mean, prep_for_boundedline(plot_se), ax(2), 'cmap', colormap(2, :))
        %
        % axis(ax(2), 'tight')
        %
        % linkaxes(ax, 'x')
        %
        % % add_stars(gca, short_BP_6min_labels'/60, p_vals(:, :, 1) < .05/bonferroni_count, [1 1], colormap)
        %
        % legend(ax(1), {'Fr. 1 - 5 Hz', 'CA1 5 - 11 Hz'})
        
        ylabel({'\fontsize{16}Power'; ['\fontsize{14}(Mean ', long_norms{n}, ')']})
        
        xlabel('Time Rel. Inj. (h)', 'FontSize', 14)
        
    end
    
end
       
save_as_pdf(gcf, 'NVP_theta_delta_timecourse')
