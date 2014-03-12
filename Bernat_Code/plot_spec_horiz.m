load('drugs.mat')

freqs=500*(0:2^9)/(2^10); freqs=freqs(freqs<=200);

for i=1:4, xlabels{i}='Time Since Injection (m)'; ylabels{i}='Frequency (Hz)'; end

channels={'Frontal','Occipital','CA1'};

stats={'median','mean'};
long_stats={'Median','Mean'};

norms={'pct','zs'};
long_norms={'Percent Change From Baseline','z-Scored'};

% for c=1:length(channels)
%     
%     for n=1:length(norms)
%         
%         for s=1:length(stats)
%             
%             index=1;
%            
%             for d=[4 1 2 3]
%                 
%                 titles{index}=[long_stats{s},' ',channels{c},' Power, ',long_norms{n},' ',drugs{d}];
%                 
%                 open(['ALL_',channels{c},'/ALL_',channels{c},'_spec_',norms{n},'_6mins_',drugs{d},'_',stats{s},'.fig'])
%             
%                 index=index+1;
%                 
%             end
%             
%             figure_replotter_labels(1:4,4,1,[(-40*6:6:0)+3,(0:6:12*10*6)-3],freqs,titles,xlabels,ylabels)
%             
%             saveas(gcf,['ALL_',channels{c},'/ALL_',channels{c},'_spec_',norms{n},'_6mins_horiz_',stats{s},'.fig'])
%             set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
%             print(gcf,'-dpdf',['ALL_',channels{c},'/ALL_',channels{c},'_spec_',norms{n},'_6mins_horiz_',stats{s},'.pdf'])
%             
%             close('all')
%             
%         end
%         
%     end
%     
% end
% 
% for c=1:length(channels)
%     
%     for n=1:length(norms)
%         
%         for s=1:length(stats)
%             
%             open(['ALL_',channels{c},'/ALL_',channels{c},'_spec_',norms{n},'_6mins_horiz_',stats{s},'.fig'])
%             
%         end
%         
%     end
%     
% end

clear titles

for d=1:3
    
    for n=1:length(norms)
        
        for s=1:length(stats)
           
            for c=1:3
                
                titles{c}=[long_stats{s},' ',channels{c},' Power, ',long_norms{n},' ',drugs{d}];
                
                open(['ALL_',channels{c},'/ALL_',channels{c},'_spec_',norms{n},'_6mins_',drugs{d},'_',stats{s},'.fig'])
                
            end
            
            figure_replotter_labels_subregion(1:3,3,1,[(-40*6:6:0)+3,(0:6:12*10*6)-3],freqs,[-120 360],[0 200],titles,xlabels,ylabels)
            
            saveas(gcf,['ALL_',drugs{d},'_spec_',norms{n},'_6mins_horiz_sub_',stats{s},'.fig'])
            set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
            print(gcf,'-dpdf',['ALL_',drugs{c},'_spec_',norms{n},'_6mins_horiz_sub_',stats{s},'.pdf'])
            
            close('all')
            
        end
        
    end
    
end

for d=1:3
    
    for n=1:length(norms)
        
        for s=1:length(stats)
            
            open(['ALL_',drugs{d},'_spec_',norms{n},'_6mins_horiz_sub_',stats{s},'.fig'])
            
        end
        
    end
    
end
