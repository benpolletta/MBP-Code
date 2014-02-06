function write_epochs_Bernat(subject)

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

states={'R','AW','NR'};
state_vals=[1 3 2];
no_states=length(states);

epoch_length=4096*4;

for s=1:no_states
    
    subj_name=[char(subject),'_',char(states{s})];
    
    data=load([subj_name,'.mat']);
    fieldnames=fields(data);
    no_channels=length(fieldnames);
    
    [~,R,W,NR]=textread([subj_name,'_VS_no_header.txt'],'%s%d%d%d%*[^\n]');
    VS=[R W NR];
    no_epochs=length(VS);
    
    for c=1:no_channels

        channel_data=getfield(data,char(fieldnames(c)));
        channel_data=getfield(channel_data,'values');
        
        writename=[subj_name,'_chan',num2str(c)];
        
        mkdir (writename)
        
        fid_epoch_list=fopen([writename,'/',writename,'_epochs.list'],'w');
        
        fid_cond_list=fopen([writename,'/',writename,'_condition_lists.list'],'w');
        
        for d=1:no_drugs
            
            drug_names{d}=[writename,'_',drugs{d},'.list'];
            fid_vec(d)=fopen([writename,'/',char(drug_names{d})],'w');
            fprintf(fid_cond_list,'%s\n',char(drug_names{d}));
            
        end
        
        fclose(fid_cond_list);
        
        max_eeg=0;
        min_eeg=0;
        
        for i=1:no_epochs
            
            state_index=find(VS(i,:)==1);
            
            state=char(states{state_index});
            
            epoch_data=channel_data(epoch_length*(i-1)+1:epoch_length*i);
            
            epoch_name=[writename,'_epoch',num2str(i),'_',state,'.txt'];
            
            fid=fopen([writename,'/',epoch_name],'w');
            fprintf(fid,'%f\n',epoch_data);
            fclose(fid);
            
            fprintf(fid_vec(state_index),'%s\n',epoch_name);
            
            state_var(i)=state_vals(state_index);
            
            fprintf(fid_epoch_list,'%s\t%d\n',epoch_name,state_var(i));
                        
            max_eeg=max(max_eeg,max(epoch_data));
            min_eeg=min(min_eeg,min(epoch_data));
            
        end
        
    end
    
    plot(state_var)
    set(gca,'YTick',0:no_states,'YTickLabel',states)
    saveas(gcf,[subj_name,'_VS_by_epoch.fig'])
    
    fclose('all');
    
end


