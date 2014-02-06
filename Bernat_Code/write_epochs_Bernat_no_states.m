function write_epochs_Bernat(subject)

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

epoch_length=4096*4;

for d=1:no_drugs
    
    subj_name=[char(subject),'_',char(drugs{d})];
    
    data=load([subj_name,'.mat']);
    fieldnames=fields(data);
    no_channels=length(fieldnames);
        
    for c=1:no_channels

        channel_data=getfield(data,char(fieldnames(c)));
        channel_data=getfield(channel_data,'values');
        
        no_epochs=floor(length(channel_data)/epoch_length);
        
        writename=[subj_name,'_chan',num2str(c)];
        
        mkdir (writename)
        
        fid_epoch_list=fopen([writename,'/',writename,'_epochs.list'],'w');
                     
        for i=1:no_epochs
                        
            epoch_data=channel_data(epoch_length*(i-1)+1:epoch_length*i);
            
            epoch_name=[writename,'_epoch',num2str(i),'.txt'];
            
            fid=fopen([writename,'/',epoch_name],'w');
            fprintf(fid,'%f\n',epoch_data);
            fclose(fid);
                        
            fprintf(fid_epoch_list,'%s\t%d\n',epoch_name,state_var(i));
                                    
        end
        
    end
    
    plot(state_var)
    set(gca,'YTick',0:no_states,'YTickLabel',states)
    saveas(gcf,[subj_name,'_VS_by_epoch.fig'])
    
    fclose('all');
    
end


