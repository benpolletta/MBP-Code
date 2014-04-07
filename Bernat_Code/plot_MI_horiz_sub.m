load('drugs.mat')

amps=20:5:200; phases=1:.25:12;

for i=1:3*10, xlabels{i}='Phase Freq. (Hz)'; end

channels={'Frontal','Occipital','CA1'};

stats={'median','mean'};
long_stats={'Median','Mean'};

[pd_labels,pd_corder]=make_period_labels(2,8,'hrs');

x_subregions=[1 4; 1 12];
y_subregions=[20 200; 20 100];
sub_labels={'delta','gamma'};

for sub=1:length(x_subregions)
    
    for c=1:length(channels)
        
        channel_name=['ALL_',channels{c}];
        measure_name=[channel_name,'_p0.99_IEzs'];
        
        for s=1:length(stats)
            
            index=1;
            
            for d=[4 1 2 3]
                
                ylabels{index}={[long_stats{s},' ',channels{c},' MI, ',drugs{d}];'Amp. Freq. (Hz)'};
                
                for p=1:length(pd_labels)
                    
                    open([channel_name,'/',measure_name,'_MI/',measure_name,'_hr_',drugs{d},'_',drugs{d},'_',pd_labels{p},'_',stats{s},'.fig'])
                    
                end
                
                index=index+1;
                
            end
            
            figure_replotter_labels_subregion(1:4*length(pd_labels),4,length(pd_labels),4,6,phases,amps,x_subregions(sub,:),y_subregions(sub,:),pd_labels,xlabels,ylabels)
            
            saveas(gcf,[channel_name,'/',measure_name,'_MI_horiz_',sub_labels{sub},'_',stats{s},'.fig'])
            set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
            print(gcf,'-dpdf',[channel_name,'/',measure_name,'_MI_horiz_',sub_labels{sub},'_',stats{s},'.pdf'])
            
            close('all')
            
        end
        
    end
    
    clear ylabels
    
    for d=1:4
        
        for s=1:length(stats)
            
            for c=1:3
                
                ylabels{c}={[long_stats{s},' ',channels{c},' MI, ',drugs{d}];'Amp. Freq. (Hz)'};
                
                channel_name=['ALL_',channels{c}];
                measure_name=[channel_name,'_p0.99_IEzs'];
                
                for p=1:length(pd_labels)
                    
                    open([channel_name,'/',measure_name,'_MI/',measure_name,'_hr_',drugs{d},'_',drugs{d},'_',pd_labels{p},'_',stats{s},'.fig'])
                    
                end
                
            end
            
            figure_replotter_labels_subregion(1:3*length(pd_labels),3,length(pd_labels),4,6,phases,amps,x_subregions(sub,:),y_subregions(sub,:),pd_labels,xlabels,ylabels)
            
            saveas(gcf,['ALL_',drugs{d},'_MI_horiz_',sub_labels{sub},'_',stats{s},'.fig'])
            set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
            print(gcf,'-dpdf',['ALL_',drugs{d},'_MI_horiz_',sub_labels{sub},'_',stats{s},'.pdf'])
            
            close('all')
            
        end
        
    end
   
    clear ylabels
    
end

for sub=1:length(x_subregions)
    
    for c=1:length(channels)
        
        for s=1:length(stats)
            
            open(['ALL_',channels{c},'/ALL_',channels{c},'_p0.99_IEzs_MI_horiz_',sub_labels{sub},'_',stats{s},'.fig'])
            
        end
        
    end
    
    for d=1:4
        
        for s=1:length(stats)
            
            open(['ALL_',drugs{d},'_MI_horiz_',sub_labels{sub},'_',stats{s},'.fig'])
            
        end
        
    end
    
end
