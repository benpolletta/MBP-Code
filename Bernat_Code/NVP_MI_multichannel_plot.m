function NVP_MI_multichannel_plot

figure

load('AP_freqs.mat')

load('channels.mat'), no_channels = length(channel_names);

short_channel_names = {'Fr.', 'Occi.', 'CA1'};

load('drugs.mat')

stats={'median', 'mean', 'std'}; no_stats = length(stats);
long_stats={'Median', 'Mean', 'St. Dev.'};

norms={'', 'pct_'}; no_norms = length(norms);
long_norms={'', 'Pct. Change From Baseline'};

no_pre=4; no_post=12;
[hr_labels, ~, long_hr_labels]=make_period_labels(no_pre,no_post,'hrs');
no_hr_periods = length(hr_labels);
    
clear titles xlabels ylabels
           
All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

for c=1:no_channels
    
    for n=1:no_norms
        
        for d = 1:no_drugs
            
            load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_p0.99_IEzs_MI',...
                '/ALL_',channel_names{c},'_p0.99_IEzs_hrMI_hr_',norms{n},drugs{d},'_cplot_data.mat'])
            
            All_cplot_data(:, :, d, :, :, c, n) = MI_stats(:, :, 1, :, :);
        
        end
        
    end
    
end

max_by_drug = reshape(max(max(max(All_cplot_data)), [], 4), no_drugs, no_stats, no_channels, no_norms);

min_by_drug = reshape(min(min(min(All_cplot_data)), [], 4), no_drugs, no_stats, no_channels, no_norms);

max_amp_data = reshape(max(All_cplot_data, [], 2), no_afs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

max_phase_data = reshape(max(All_cplot_data), no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

plot_start_hr = 5; plot_end_hr = 8; no_plot_hrs = plot_end_hr - plot_start_hr + 1;

for n = 1 %:no_norms
    
    for s = 1 %:no_stats
        
        for d = 3 % 1:no_drugs
            
            for c = 1:no_channels
                
                for h = plot_start_hr:plot_end_hr
                    
                    subplot(no_channels, no_plot_hrs, (c - 1)*no_plot_hrs + h - plot_start_hr + 1)
                    
                    imagesc(phase_freqs, amp_freqs, All_cplot_data(:, :, d, h, s, c, n))
                    
                    caxis([min_by_drug(d, s, c, n) max_by_drug(d, s, c, n)])
                    
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
            
        end
        
    end
    
end
                
save_as_pdf(gcf,'NVP_MI_multichannel_post1to4_median')
