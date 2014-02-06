function [MI_all]=wavelet_mouse_eeg_collect_Bernat_by_state(subject,channel,amp_lims,phase_lims)

% amp_limits and phase_limits are row vectors containing limits on
% amplitude and phase frequencies, respectively.

close('all')

bands_lo=4:.25:12;
bands_hi=20:5:180;

% noamps=length(bands_lo);
% nophases=length(bands_hi);

amp_indices=find(bands_hi>=amp_lims(1) & bands_hi<=amp_lims(2));
phase_indices=find(bands_lo>=phase_lims(1) & bands_lo<=phase_lims(2));

freq_label=[num2str(amp_lims(1)),'to',num2str(amp_lims(2)),'by',num2str(phase_lims(1)),'to',num2str(phase_lims(2))];
freq_label_long=[num2str(amp_lims(1)),' Hz to ',num2str(amp_lims(2)),' Hz Amplitude by ',num2str(phase_lims(1)),' Hz to ',num2str(phase_lims(2)),' Hz Phase'];

present_dir=pwd;

% Setting up information about periods (time since injection).

period_hrs=[-4 0;0 4;4 8];
[no_periods,~]=size(period_hrs);

if strcmp(subject,'A99') && channel==1
    period_labels={'pre','post1to4','post4to8'};
else
    period_labels={'pre','post1to4','post5to8'};
end
    
data_pts_per_epoch=4096;
sampling_rate=250;
seconds_per_epoch=data_pts_per_epoch/sampling_rate;
epochs_per_min=60/seconds_per_epoch;
epochs_per_hour=60*60/seconds_per_epoch;

inj_epochs=floor([5*60+7 2*60+35 5*60+7 3*60]*epochs_per_min);
% total_epochs=[5236 4881 7354 4938];

% Setting up information about different states.

states={'R','NR','AW'};
no_states=length(states);

state_labels={'Active Wake','NREM / Quiet Wake','REM','Injection'};
state_markers={'.r','.g','.b'};
state_sizes=[20 10 10];

for i=1:no_states
    state_dirs{i}=[char(subject),'_chan',num2str(channel),'_',char(states(i))];
end

% Setting up information about different measures.

measures={'IE','canMI','PLV'};
no_measures=length(measures);

measure_labels={'Inverse Entropy','Canolty MI','Phase-Locking Value'};

% Working with different drugs.

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

for d=1:no_drugs
    
    data_dir=[subject,'_',drugs{d},'_chan',num2str(channel)];
        
    epoch_list=[data_dir,'_epochs.list'];

    [epoch_names,epoch_states]=textread([data_dir,'/',epoch_list],'%s%d%*[^\n]');
%     no_epochs=length(epoch_names);

    start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
    start_epochs=max(start_epochs,1);
    
    end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
    
    drug_epoch_names=epoch_names(start_epochs(1):end_epochs(end));
    drug_epoch_states=epoch_states(start_epochs(1):end_epochs(end));
    
%     epochs_per_period=end_epochs-start_epochs+1;
    
    total_epochs=end_epochs(end)-max(start_epochs(1),1)+1;
    
    t=(1:total_epochs)*seconds_per_epoch/(60*60);
    
    % Setting up file for recording measures of PAC.
       
    all_dirname=['ALL_',epoch_list(1:end-5)];
    mkdir (all_dirname)

    fid=fopen([all_dirname,'/',all_dirname,'_',freq_label,'.txt'],'w');
    fprintf(fid,'%s\t%s\t','epoch','state');
    for i=1:no_measures
        fprintf(fid,'%s\t',measures{i});
    end
    fprintf(fid,'%s\n','');
        
    MI_all=zeros(total_epochs,3);

    % Retrieving PAC measures epoch by epoch.
    
    for ps=1:1

%         start_epoch=start_epochs(p);
%         end_epoch=end_epochs(p);
%         
%         epochs_in_period=epochs_per_period(p);
        
        for j=(start_epochs(p)-start_epochs(1)+1):(end_epochs(p)-start_epochs(1)+1)
            
            epoch_state=drug_epoch_states(j);
            
%             if epoch_state<no_states
            
            state_dir=state_dirs{epoch_state};
            
            period_dir=[state_dir,'_',char(drugs{d}),'_',period_labels{p}];
                        
            %         dir_name=char(condition_dirs{epoch_state+1});
            state_dir=char(state_dir);
            
            epoch_name=char(drug_epoch_names(j));
            epoch_name=epoch_name(1:end-4);
            
            filenames{1}=[state_dir,'/',period_dir,'/',epoch_name,'_IE.mat'];
            filenames{2}=[state_dir,'/',period_dir,'/',period_dir,'_canolty/',epoch_name,'_canolty_MI.mat'];
            filenames{3}=[state_dir,'/',period_dir,'/',period_dir,'_PLV/',epoch_name,'_PLV.mat'];
            
            fprintf(fid,'%s\t%d\t',epoch_name,epoch_state);
            
            for i=1:no_measures
                
                MI=load(char(filenames{i}),'MI');
                MI=MI.MI;
                
                mean_MI=sum(sum(MI(amp_indices,phase_indices)));
                
                MI_all(j,i)=MI_sum;
                
                fprintf(fid,'%f\t',MI_sum);
                
            end
            
            fprintf(fid,'%s\n','');
                    
        end
            
    end
    
    fclose('all');
    
    save([all_dirname,'/',all_dirname,'_',freq_label,'.mat'],'MI_all')
               
    for m=1:no_measures
                      
        figure(m)
        
        subplot(4,1,d)
        
        for s=no_states:-1:1
            
            state_indices=find(drug_epoch_states==s);
            
            plot(t(state_indices),MI_all(state_indices,m),state_markers{s},'MarkerSize',state_sizes(s))
           
            hold on
            
        end

%         plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
                     
        if d==1
            
%             legend(state_labels)
            title({['Summed ',measure_labels{m}];freq_label_long})
            
        end
        
        xlabel('Time (h)')
        ylabel(drugs{d})
        
        figure(no_measures+(d-1)*no_measures+m)
        
        for s=no_states:-1:1
            
            state_indices=find(drug_epoch_states==s);
            
            plot(t(state_indices),MI_all(state_indices,m),state_markers{s},'MarkerSize',state_sizes(s))
            
            hold on
            
        end
        
        plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
        
        legend(state_labels)
        title({['Summed ',measure_labels{m},' for ',drugs{d}];freq_label_long})
        xlabel('Time (h)')
        ylabel(['Summed ',measure_labels{m}])
        
        saveas(gcf,[all_dirname,'/',all_dirname,'_',measures{m},'_',freq_label,'.fig'])
        
    end
    
    cd (present_dir);

end

max_MI=max(MI_all);

for m=1:no_measures
            
    figure(m)
        
    for d=1:no_drugs
        
        start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
        start_epochs=max(start_epochs,1);
        
        end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
        
        total_epochs=end_epochs(end)-start_epochs(1)+1;
        
        t=(1:total_epochs)*seconds_per_epoch/(60*60);
        
        subplot(4,1,d)
        
        ylim([0 max_MI(m)])
        
        plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)

    end
    
    saveas(gcf,[subject,'_chan',num2str(channel),'_',measures{m},'_',freq_label,'.pdf'])

    subplot(4,1,1)
    
    legend(state_labels)
    
    saveas(gcf,[subject,'_chan',num2str(channel),'_',measures{m},'_',freq_label,'.fig'])
    
end