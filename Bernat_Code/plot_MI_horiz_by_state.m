load('drugs.mat')

amps=20:5:200; phases=1:.25:12;

for i=1:3*10, xlabels{i}='Phase Freq. (Hz)'; end

channels={'Frontal','Occipital','CA1'};

stats={'median','mean'};
long_stats={'Median','Mean'};

states={'W','NR','R'};
long_states={'Active Wake','NREM/Quiet Wake','REM'};

[pd_labels,pd_corder]=make_period_labels(4,16,'4hrs');

% for c=1:length(channels)
%     
%     channel_name=['ALL_',channels{c}];
%     measure_name=[channel_name,'_p0.99_IEzs'];
%     
%     for s=1:length(stats)
%         
%         for st=1:length(states)
%             
%             index=1;
%             
%             for d=[4 1 2 3]
%                 
%                 ylabels{index}={[long_stats{s},' ',long_states{st},' ',channels{c},' MI, ',drugs{d}];'Amp. Freq. (Hz)'};
%                 
%                 for p=1:length(pd_labels)
%                     
%                     open([channel_name,'/',measure_name,'_MI/',measure_name,'_4hr_',drugs{d},'_',states{st},'_',pd_labels{p},'_',stats{s},'.fig'])
%                     
%                 end
%                 
%                 index=index+1;
%                 
%             end
%             
%             figure_replotter_labels(1:4*length(pd_labels),4,length(pd_labels),phases,amps,pd_labels,xlabels,ylabels)
%             
%             saveas(gcf,[channel_name,'/',measure_name,'_MI_horiz_',states{st},'_',stats{s},'.fig'])
%             set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
%             print(gcf,'-dpdf',[channel_name,'/',measure_name,'_MI_horiz_',states{st},'_',stats{s},'.pdf'])
%             
%             close('all')
%             
%         end
%         
%     end
%     
% end

clear ylabels

for d=1:4
    
    for s=1:length(stats)
        
        for st=1:length(states)
            
            for c=1:3
                
                ylabels{c}={[long_stats{s},' ',long_states{st},' ',channels{c},' MI, ',drugs{d}];'Amp. Freq. (Hz)'};
                
                channel_name=['ALL_',channels{c}];
                measure_name=[channel_name,'_p0.99_IEzs'];
                
                for p=1:length(pd_labels)
                    
                    open([channel_name,'/',measure_name,'_MI/',measure_name,'_4hr_',drugs{d},'_',states{st},'_',pd_labels{p},'_',stats{s},'.fig'])
                    
                end
                
            end
            
            figure_replotter_labels(1:3*length(pd_labels),3,length(pd_labels),phases,amps,pd_labels,xlabels,ylabels)
            
            saveas(gcf,['ALL_',drugs{d},'_MI_horiz_',states{st},'_',stats{s},'.fig'])
            set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
            print(gcf,'-dpdf',['ALL_',drugs{d},'_MI_horiz_',states{st},'_',stats{s},'.pdf'])
            
            close('all')
            
        end
        
    end
    
end

for c=1:length(channels)
    
    for s=1:length(stats)
        
        for st=1:length(states)
            
            open(['ALL_',channels{c},'/ALL_',channels{c},'_p0.99_IEzs_MI_horiz_',states{st},'_',stats{s},'.fig'])
            
        end
        
    end
    
end

for d=1:4
    
    for s=1:length(stats)
       
        for st=1:length(states)
            
            open(['ALL_',drugs{d},'_MI_horiz_',states{st},'_',stats{s},'.fig'])
            
        end
        
    end
    
end
