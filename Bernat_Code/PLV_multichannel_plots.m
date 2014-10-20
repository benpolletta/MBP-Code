function PLV_multichannel_plots

freqs = [1:.25:12 20:5:200];

bands = [1 12; 20 200]; no_bands = size(bands, 1);

[band_indices, long_band_names] = deal(cell(no_bands, 1));

for b = 1:no_bands
    
    band_indices{b} = freqs >= bands(b, 1) & freqs <= bands(b,2);
    long_band_names{b} = sprintf('%d to %d Hz', bands(b, 1), bands(b, 2));

end
    
load('channels.mat')

channel_pairs = nchoosek(1:3,2);
no_chan_pairs = size(channel_pairs,1);

[cp_labels, chanpair_labels] = deal(cell(no_chan_pairs, 1));

for cp = 1:no_chan_pairs
    
    cp_labels{cp} = [channel_names{channel_pairs(cp, 1)}, '_by_', channel_names{channel_pairs(cp, 2)}];
    
    chanpair_labels{cp} = [channel_names{channel_pairs(cp, 1)}, ' by ', channel_names{channel_pairs(cp, 2)}];
    
end
    
load('drugs.mat')

%for i=1:no_chan_pairs, xlabels{i}='Time Since Injection (h)'; ylabels{i}={channel_names{i};'Frequency (Hz)'}; end

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
           
All_cplot_data = nan(length(freqs), no_drugs, no_6min_periods, no_stats, no_chan_pairs, no_norms);
           
All_lineplot_data = nan(length(freqs), no_drugs, no_hr_periods, no_stats, no_chan_pairs, no_norms);

for c=1:no_chan_pairs
    
    for n=1:no_norms
        
        load(['ALL_',cp_labels{c},'_PLV/ALL_',cp_labels{c},'_PLV_',norms{n},'6mins_spec_stats_for_cplot.mat'])
        
        All_cplot_data(:, :, :, :, c, n) = spec_stats;
        
        load(['ALL_',cp_labels{c},'_PLV/ALL_',cp_labels{c},'_PLV_',norms{n},'hrs_spec_stats_for_cplot.mat'])
        
        All_lineplot_data(:, :, :, :, c, n) = spec_stats;
        
    end
    
end

handle = nan(no_drugs, no_norms, no_stats);

for n = 1:no_norms
    
    for s = 1:no_stats
        
        for d = 1:no_drugs
            
            handle(d, n, s) = figure;
            
            for c = 1:no_chan_pairs
                
                for b = 1:no_bands
                    
                    subplot(no_chan_pairs + 2, 2, (c - 1)*2 + b)
                    
                    imagesc(str2num(char(sixmin_labels)), freqs(band_indices{b}), reshape(All_cplot_data(band_indices{b}, d, :, s, c, n), sum(band_indices{b}), no_6min_periods))
                    
                    axis xy
                    
                    if b == 1
                    
                        ylabel({chanpair_labels{c};'Frequency (Hz)'})
                    
                    end
                        
                    if c == 1
                        
                        title({[drugs{d}, ', ', long_band_names{b}]; [long_stats{s}, ' PLV, ', long_norms{n}]})
                        
                    elseif c == 3
                        
                        xlabel('Time Rel. Injection (min.)')
                        
                    end
                    
                end
                
            end
            
            for h = 5:9
                
                for b = 1:no_bands
                    
                    subplot(no_chan_pairs + 2, 5, (no_chan_pairs + b -1)*5 + h - 4)
                    
                    plot(freqs(band_indices{b})', reshape(All_lineplot_data(band_indices{b}, d, h, s, :, n), sum(band_indices{b}), no_chan_pairs))
                    
                    title(long_hr_labels{h})
                    
                    xlabel('Frequency (Hz)')
                    
                    axis tight
                    
                    if h == 5 && b == 1
                        
                        legend(chanpair_labels, 'Location', 'NorthWest')
                        
                        ylabel({[long_stats{s}, ' Power']; long_norms{n}})
                        
                    end
                    
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
