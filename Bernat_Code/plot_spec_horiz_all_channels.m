function plot_spec_horiz_all_channels(hour_lims,freq_lims,no_hr_ticks,no_freq_ticks,clims)

freq_label = sprintf('%g-%g',freq_lims(1),freq_lims(2));
load('drugs.mat')

freqs=500*(0:2^9)/(2^10); freqs=freqs(freqs<=200);

for i=1:4, xlabels{i}='Time Since Injection (h)'; ylabels{i}={drugs{i};'Frequency (Hz)'}; end

channels={'Frontal','Occipital','CA1'};

stats={'median','mean'};
long_stats={'Median','Mean'};

norms={'','pct_','zs_'};
long_norms={'','Percent Change From Baseline','z-Scored'};

    
for n=1:1%1:length(norms)
    
    for s=1:length(stats)
        
        %         index=1;
        
        for d=1:4
            
            for c=1:length(channels)
                
                titles{c}={[long_stats{s},' ',channels{c},' Power'];long_norms{n}};
                
                open(['ALL_',channels{c},'/ALL_',channels{c},'_spec_',norms{n},'6mins_',drugs{d},'_',stats{s},'.fig'])
                
                %                 index=index+1;
                
            end
            
        end
        
        %             figure_replotter_labels(1:12,4,3,9,5,[(-40*6:6:0)+3,(0:6:12*10*6)-3],freqs,titles,xlabels,ylabels)
        figure_replotter_labels_subregion(1:12,4,3,clims,no_hr_ticks,no_freq_ticks,[(-4*10*6:6:0)+3,(0:6:12*10*6)-3]/60,freqs,hour_lims,freq_lims,titles,xlabels,ylabels)
        
        saveas(gcf,['ALL_spec_',norms{n},'6mins_horiz_',stats{s},'_',freq_label,'.fig'])
        set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
        print(gcf,'-dpdf',['ALL_spec_',norms{n},'6mins_horiz_',stats{s},'_',freq_label,'.pdf'])
        
        close('all')
        
    end
    
end
    
for n=1:1%length(norms)
    
    for s=1:length(stats)
        
        open(['ALL_spec_',norms{n},'6mins_horiz_',stats{s},'_',freq_label,'.fig'])
        
    end
    
end
    
clear titles

% for d=1:3
%     
%     for n=1:length(norms)
%         
%         for s=1:length(stats)
%            
%             for c=1:3
%                 
%                 titles{c}=[long_stats{s},' ',channels{c},' Power, ',long_norms{n},' ',drugs{d}];
%                 
%                 open(['ALL_',channels{c},'/ALL_',channels{c},'_spec_',norms{n},'6mins_',drugs{d},'_',stats{s},'.fig'])
%                 
%             end
%             
%             figure_replotter_labels_subregion(1:3,3,1,8,6,[(-40*6:6:0)+3,(0:6:12*10*6)-3],freqs,[-120 360],[0 200],titles,xlabels,ylabels)
%             
%             saveas(gcf,['ALL_',drugs{d},'_spec_',norms{n},'6mins_horiz_sub_',stats{s},'.fig'])
%             set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
%             print(gcf,'-dpdf',['ALL_',drugs{d},'_spec_',norms{n},'6mins_horiz_sub_',stats{s},'.pdf'])
%             
%             close('all')
%             
%         end
%         
%     end
%     
% end
% 
% for d=1:3
%     
%     for n=1:length(norms)
%         
%         for s=1:length(stats)
%             
%             open(['ALL_',drugs{d},'_spec_',norms{n},'6mins_horiz_sub_',stats{s},'.fig'])
%             
%             set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
%             print(gcf,'-dpdf',['ALL_',drugs{d},'_spec_',norms{n},'6mins_horiz_sub_',stats{s},'.pdf'])
%             
%         end
%         
%     end
%     
% end
