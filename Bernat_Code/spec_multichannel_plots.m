function spec_multichannel_plots%(hour_lims,freq_lims,no_hr_ticks,no_freq_ticks,clims)

% SAMPLE CALL: plot_spec_horiz_all_channels([-120 360], [0 200], 8, 6, 'rows')

%freq_label = sprintf('%g-%g',freq_lims(1),freq_lims(2));

freqs=500*(1:2^9)/(2^10); freqs=freqs(freqs<=200);

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat')

%for i=1:no_channels, xlabels{i}='Time Since Injection (h)'; ylabels{i}={channel_names{i};'Frequency (Hz)'}; end

stats={'median','mean','std'}; no_stats = length(stats);
long_stats={'Median','Mean','St. Dev.'};

norms={'pct_','zs_'}; no_norms = length(norms);
long_norms={'Percent Change From Baseline','z-Scored'};

no_pre=4; no_post=12;
[sixmin_labels, ~]=make_period_labels(no_pre,no_post,'6mins');
no_6min_periods = length(sixmin_labels);

no_pre=4; no_post=12;
[hr_labels, ~, long_hr_labels]=make_period_labels(no_pre,no_post,'hrs');
no_hr_periods = length(hr_labels);
    
clear titles xlabels ylabels

%for i=1:3, xlabels{i}='Time Since Injection (h)'; ylabels{i}=; end
           
All_cplot_data = nan(length(freqs), no_drugs, no_6min_periods, no_stats, no_channels, no_norms);
           
All_lineplot_data = nan(length(freqs), no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

for c=1:no_channels
    
    for n=1:no_norms
        
        % titles{c}=[long_stats{s},' ',channels{c},' Power, ',long_norms{n},' ',drugs{d}];
        
        load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_spec_',norms{n},'6mins_spec_stats_for_cplot.mat'])
        
        All_cplot_data(:, :, :, :, c, n) = spec_stats;
        
        load(['ALL_',channel_names{c},'/ALL_',channel_names{c},'_spec_',norms{n},'hrs_spec_stats_for_cplot.mat'])
        
        All_lineplot_data(:, :, :, :, c, n) = spec_stats;
        
    end
    
end

handle = nan(no_drugs, no_norms, no_stats);

for n = 1:no_norms
    
    for s = 1:no_stats
        
        for d = 1:no_drugs
            
            handle(d, n, s) = figure;
            
            for c = 1:no_channels
                
                subplot(no_channels + 1, 1, c)
                
                imagesc(str2num(char(sixmin_labels)), freqs, reshape(All_cplot_data(:, d, :, s, c, n), length(freqs), no_6min_periods))
                
                axis xy
                
                ylabel({channel_names{c};'Frequency (Hz)'})
                
                if c == 1
                    
                    title({drugs{d}; [long_stats{s}, ' Power, ', long_norms{n}]})
                    
                elseif c == 3
                    
                    xlabel('Time Rel. Injection (min.)')
                    
                end
                
            end
            
            for h = 5:9
                
                subplot(no_channels + 1, 5, no_channels*5 + h - 4)
            
                plot(freqs', reshape(All_lineplot_data(:, d, h, s, :, n), length(freqs), no_channels))
                
                title(long_hr_labels{h})
                
                xlabel('Frequency (Hz)')
                
                if h == 5
                    
                    legend(channel_names, 'Location', 'SouthEast')
                    
                    ylabel({[long_stats{s}, ' Power']; long_norms{n}})
                    
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
