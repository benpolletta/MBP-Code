function MI_multichannel_plots%(hour_lims,freq_lims,no_hr_ticks,no_freq_ticks,clims)

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
    
clear titles xlabels ylabels
           
All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

for c=1:no_channels
    
    for n=1:no_norms
        
        for d = 1:no_drugs
            
            load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_p0.99_IEzs_MI',...
                '/ALL_',channel_names{c},'_p0.99_IEzs_hr_',norms{n},drugs{d},'_cplot_data.mat'])
            
            All_cplot_data(:, :, d, :, :, c, n) = MI_stats(:, :, 1, :, :);
        
        end
        
    end
    
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
            
            for c = 1:no_channels
                
                for h = 3:10
                    
                    subplot(no_channels + 2, 8, (c - 1)*8 + h - 2)
                    
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
            
            no_hours = 5;
            
            for h = (1:no_hours) + 4
                
                subplot(no_channels + 2, no_hours, no_channels*no_hours + h - 4)
            
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
                
                subplot(no_channels + 2, no_hours, (no_channels + 1)*no_hours + h - 4)
            
                plot(phase_freqs', reshape(max_phase_data(:, d, h, s, :, n), no_pfs, no_channels))
                
                axis tight
                
                yl = ylim;
                
                ylim([yl(1) max(max_by_drug(d, s, :, n), [], 3)])
                
                xlabel('Phase Freq. (Hz)')
                
                if h == 5
                    
                    ylabel({['Max. ', long_stats{s}, ' MI']; long_norms{n}})
                    
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
