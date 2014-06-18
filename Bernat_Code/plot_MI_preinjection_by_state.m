load('drugs.mat')

amps=20:5:200; phases=1:.25:12;

for i=1:3*10, xlabels{i}='Phase Freq. (Hz)'; end

channels={'Frontal','Occipital','CA1'};

stats={'median'};
long_stats={'Median'};

[pd_labels,pd_corder]=make_period_labels(2,8,'hrs');

x_subregions=[1 12; 1 12];
y_subregions=[100 200; 20 200];
sub_labels={'HFO','all'};

states = {'W','NR','R'};

for sub=1:size(x_subregions,1)
    
    for sl = 1:3
        
        for d = 1:4
            
            title_index = 1;
            
            for c=1:length(channels)
                
                channel_name=['ALL_',channels{c}];
                measure_name=[channel_name,'_p0.99_IEzs'];
                
                for st=1:length(stats)
                    
                    for p=1:2%length(pd_labels)
                        
                        titles{title_index} = [channels{c},' ',states{sl},', ',pd_labels{p}];
                        
                        title_index = title_index + 1;
                        
                        open([channel_name,'/',measure_name,'_MI/',measure_name,'_hr_by_state_',drugs{d},'_',states{sl},'_',pd_labels{p},'_',stats{st},'.fig'])
                        
                    end
                    
                end
                
            end
            
        end
        
        figure_replotter_labels_subregion(1:4*2*3,4,2*3,[],5,6,phases,amps,x_subregions(sub,:),y_subregions(sub,:),titles,xlabels,drugs)
        
        save_as_pdf(gcf,['All_MI_pre_',sub_labels{sub},'_',states{sl},'_',stats{st},'_cbar'])
        
        close('all')
        
        clear ylabels
        
%         for d=1:1
%             
%             for st=1:length(stats)
%                 
%                 for c=1:3
%                     
%                     ylabels{c}=[channels{c},' ',states{sl},', ',drugs{d}];
%                     
%                     channel_name=['ALL_',channels{c}];
%                     measure_name=[channel_name,'_p0.99_IEzs'];
%                     
%                     for p=1:length(pd_labels)
%                         
%                         open([channel_name,'/',measure_name,'_MI/',measure_name,'_hr_by_state_',drugs{d},'_',states{sl},'_',pd_labels{p},'_',stats{st},'.fig'])
%                         
%                     end
%                     
%                 end
%                 
%                 figure_replotter_labels_subregion(1:3*length(pd_labels),3,length(pd_labels),'rows',3,6,phases,amps,x_subregions(sub,:),y_subregions(sub,:),pd_labels,xlabels,ylabels)
%                 
%                 save_as_pdf(gcf,['ALL_',drugs{d},'_MI_horiz_',sub_labels{sub},'_',states{sl},'_',stats{st},'_rownorm'])
%                 
%                 close('all')
%                 
%             end
%             
%         end
        
    end
    
end

for sub=1:size(x_subregions,1)
    
    for sl = 1:3
        
        for st=1:length(stats)
            
            open(['All_MI_pre_',sub_labels{sub},'_',states{sl},'_',stats{st},'_cbar.fig'])
            
        end
        
%         for d=1:1
%             
%             for st=1:length(stats)
%                 
%                 open(['ALL_',drugs{d},'_MI_horiz_',sub_labels{sub},'_',states{sl},'_',stats{st},'_rownorm.fig'])
%                 
%             end
%             
%         end
        
    end
    
end
