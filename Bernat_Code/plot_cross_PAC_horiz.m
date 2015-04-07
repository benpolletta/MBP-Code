function plot_cross_PAC_horiz(norm)

load('drugs.mat')

no_drugs = length(drugs);

amps=20:5:200; phases=1:.25:12;

channels={'Frontal','Occipital','CA1'};

channel_pairs = [1 3; 3 1]; no_chan_pairs = size(chan_pairs, 1);

for i = 1:no_chan_pairs*10, xlabels{i} = 'Phase Freq. (Hz)'; end

stats={'median','mean'};
long_stats={'Median','Mean'};

[pd_labels, pd_corder] = make_period_labels(2,8,'hrs');

for c=1:no_chan_pairs
            
    channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
    
    for s=1:length(stats)
        
        index = 1;
        
        for d = [4 1 2 3]
            
            ylabels{index} = {[long_stats{s},' ', channels{chan_pairs(c, 1)}, ' by ', channels{chan_pairs(c, 1)}, ' MI, ', drugs{d}]; 'Amp. Freq. (Hz)'};
            
            for p=1:length(pd_labels)
                
                open([channel_name, '/', channel_name, norm, '_hr_', drugs{d}, '_', drugs{d}, '_', pd_labels{p}, '_', stats{s}, '.fig'])
                
            end
            
            index=index+1;
            
        end
        
        figure_replotter_labels(1:4*length(pd_labels), 4, length(pd_labels), 4, 7, phases, amps, pd_labels, xlabels, ylabels)
        
        saveas(gcf,[channel_name,'/',measure_name,'_MI_horiz_',stats{s},'.fig'])
        set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
        print(gcf,'-dpdf',[channel_name,'/',measure_name,'_MI_horiz_',stats{s},'.pdf'])
        
        close('all')
        
    end
    
end

clear ylabels

for d = 1:no_drugs
    
    for s = 1:length(stats)
        
        for c = 1:no_chan_pairs
            
            ylabels{c} = {[long_stats{s},' ',channels{c},' MI, ',drugs{d}];'Amp. Freq. (Hz)'};
            
            channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
            
            for p=1:length(pd_labels)
                
                open([channel_name, '/', channel_name, norm, '_hr_', drugs{d}, '_', drugs{d}, '_', pd_labels{p}, '_', stats{s}, '.fig'])
                
            end
            
        end
        
        figure_replotter_labels(1:no_chan_pairs*length(pd_labels), no_chan_pairs, length(pd_labels), 'rows+', 4, 7, phases, amps, pd_labels, xlabels, ylabels)
        
        saveas(gcf, ['ALL_', drugs{d}, '_cross_MI_horiz_', stats{s}, '.fig'])
        set(gcf, 'PaperOrientation', 'landscape', 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1])
        print(gcf, '-dpdf', ['ALL_', drugs{d}, '_cross_MI_horiz_', stats{s}, '.pdf'])
        
        close('all')
        
    end
    
end

for c=1:length(channels)
    
    for s=1:length(stats)
        
        open(['ALL_',channels{c},'/ALL_',channels{c},'_p0.99_IEzs_MI_horiz_',stats{s},'.fig'])
        
    end
    
end

for d=1:4
    
    for s=1:length(stats)
        
        open(['ALL_',drugs{d},'_MI_horiz_',stats{s},'.fig'])
        
    end
    
end
