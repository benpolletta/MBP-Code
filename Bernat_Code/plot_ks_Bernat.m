function plot_ks_Bernat(channel_name,measure)

name=sprintf('ALL_%s',channel_name);

load([name,'/',name,'_',measure,'_ks.mat'])

load('subjects.mat')
no_subs=length(subjects);
load('drugs.mat')
no_drugs=length(drugs);
load('states.mat')
no_states=length(states);
load('AP_freqs.mat')
no_amps=length(amp_freqs);
amp_ticks=1:ceil(no_amps/5):no_amps;
no_phases=length(phase_freqs);
phase_ticks=1:ceil(no_phases/5):no_phases;
hrs=make_period_labels(8,16,'hrs');
no_hrs=length(hrs);
fourhrs=make_period_labels(8,16,'4hrs');
no_4hrs=length(fourhrs);

no_f_pairs=size(ks_hrs,1);

[rows,cols]=subplot_size(no_hrs);

for s=1:no_subs
    
    subject=subjects{s};
    
    for d=1:no_drugs
        
        drug=drugs{d};
        
        figure()
        
        for h=1:no_hrs
            
            hour=hrs{h};
           
            subplot(rows,cols,h)
            
            imagesc(-log(reshape(ks_hrs(:,h,d,s),no_amps,no_phases)))
            
            axis xy
            
            caxis([-log(.05/(no_amps*no_phases*no_subs*no_drugs*no_hrs)) -log(.001/(no_amps*no_phases*no_subs*no_drugs*no_hrs))])
            
            colorbar
            
            set(gca,'XTick',phase_ticks,'XTickLabel',phase_freqs(phase_ticks),'YTick',amp_ticks,'YTickLabel',amp_freqs(amp_ticks))
            
            if mod(h,cols)==1
               
                ylabel('Amp. Freq. (Hz)')
                
            end
            
            if h==round(cols/2)
                
                title({sprintf('%s, %s',subject,drug);hour})
                
            else
                
                title(hour)
                
            end
            
            if abs(rows*cols)-h>=cols
                
                xlabel('Phase Freq. (Hz)')
                
            end
            
        end
        
        saveas(gcf,[name,'/',name,'_',measure,'_',subject,'_',drug,'_ks.fig'])
        
%         figure()
%         
%         for st=1:no_states
%             
%             state=states{st};
%             
%             for h=1:no_4hrs
%                 
%                 hour=fourhrs{h};
%                 
%                 subplot(no_states,no_4hrs,(st-1)*no_4hrs+h)
%                 
%                 imagesc(-log(reshape(ks_4hrs(:,h,d,s),no_amps,no_phases)))
%                 
%                 axis xy
%                 
%                 colorbar
%                 
%                 set(gca,'XTick',phase_ticks,'XTickLabel',phase_freqs(phase_ticks),'YTick',amp_ticks,'YTickLabel',amp_freqs(amp_ticks))
%                 
%             end
%             
%         end
        
    end
    
end