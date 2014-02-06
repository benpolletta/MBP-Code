function wavelet_mouse_eeg_plot_Bernat_by_phase(subject,channel)

close('all')

bands_lo=4:.25:12;
bands_hi=20:5:180;

noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

% Setting up information about periods (time since injection).

% period_hrs=[-4 0;0 4;4 8];
% [no_periods,~]=size(period_hrs);
% 
% if strcmp(subject,'A99') && channel==1
%     period_labels={'pre','post1to4','post4to8'};
% else
%     period_labels={'pre','post1to4','post5to8'};
% end
    
data_pts_per_epoch=4096;
sampling_rate=250;
seconds_per_epoch=data_pts_per_epoch/sampling_rate;
epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

inj_epochs=floor([5*60+7 2*60+35 5*60+7 3*60]*epochs_per_min);
% total_epochs=[5236 4881 7354 4938];

% Setting up information about different states.

states={'R','NR','AW'};
no_states=length(states);

% state_labels={'Active Wake','NREM / Quiet Wake','REM','Injection'};
state_markers={'.r','.g','.b'};
% state_sizes=[20 10 10];

% for i=1:no_states
%     state_dirs{i}=[char(subject),'_chan',num2str(channel),'_',char(states(i))];
% end

% Setting up information about different measures.

measures={'IE','canMI','PLV'};
no_measures=length(measures);

measure_labels={'Inverse Entropy','Canolty MI','Phase-Locking Value'};

% Working with different drugs.

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

for d=1:no_drugs
    
    all_dirname=['ALL_',subject,'_',drugs{d},'_chan',num2str(channel),'_epochs'];
    
    cd (all_dirname)
    
    fid=fopen([all_dirname,'_IE.txt'],'r');
    epoch_states=textscan(fid,'%*[^\t]%d%*[^\n]','Headerlines',1);
    fclose(fid);
    
    epoch_states=epoch_states{1};
    
    no_epochs=length(epoch_states);
        
    t=(1:no_epochs)*seconds_per_epoch/(60*60);
                   
    for m=1:no_measures

        load([all_dirname,'_',measures{m},'.mat'])
        
        MI_all_norm=(MI_all-ones(size(MI_all))*diag(mean(MI_all)))*diag(1./std(MI_all));
                      
        MI_all_norm(inj_epochs(d),:)=nan;
        
        for p=1:no_bands_lo
            
            figure(m)
            
            subplot(no_drugs*2,1,2*d-1)
            
            imagesc(MI_all_norm(:,(p-1)*noamps:p*nophases)')
            
            colorbar
            
            if d==1
                
                title({measure_labels{m};['For ',num2str(bands_lo(p)),' Hz Phase']})
                
            end
            
            set(gca,'YTickLabel',bands_hi)
            xlabel('Time (h)')
            ylabel(drugs{d})
            
            subplot(no_drugs*2,1,2*d-1)
            
            for s=no_states:-1:1
                
                state_indices=find(epoch_states==s);
                
                plot(t(state_indices),zeros(size(state_indices)),state_markers{s})
                
                hold on
                
            end
            
            box
            
            set(gca,'XTick',[],'YTick',[])
            
            figure(no_measures+(d-1)*no_measures+m)
            
            subplot(2,1,1)
            
            imagesc(MI_all_norm(:,(p-1)*noamps:p*nophases)')
            
            colorbar
            
            title({[measure_labels{m},' for ',subject,' Channel ',num2str(channel),' ',drugs{d}];['For ',num2str(bands_lo(p)),' Hz Phase']})
            
            set(gca,'YTickLabel',bands_hi)
            xlabel('Time (h)')
            ylabel(measure_labels{m})
            
            subplot(2,1,2)
            
            for s=no_states:-1:1
                
                state_indices=find(epoch_states==s);
                
                plot(t(state_indices),zeros(size(state_indices)),state_markers{s})
                
                hold on
                
            end
            
            box
            
            set(gca,'XTick',[],'YTick',[])
            
            saveas(gcf,[all_dirname,'/',all_dirname,'_',measures{m},'_p',num2str(bands_lo(p)),'.fig'])
        
            close(gcf)
            
        end
                        
    end
    
    cd (present_dir);

end

for m=1:no_measures

    saveas(figure(m),[subject,'_chan',num2str(channel),'_',measures{m},'_p',num2str(bands_lo(p)),'.fig'])
    
end