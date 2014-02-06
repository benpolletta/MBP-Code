function write_epochs_Bernat_simple(subject,drug,channels)

no_channels=length(channels);

present_dir=pwd;

epoch_length=4096*4;

subj_name=[char(subject),'_',char(drug)];

data=load([subj_name,'.mat']);
fieldnames=fields(data);

mkdir (subj_name)
cd (subj_name)

fid_channels_list=fopen([subj_name,'_channels.list'],'w');

for c=1:no_channels
    
    writename=[subj_name,'_chan',num2str(channels(c))]
        
    epoch_list_name=[writename,'_epochs.list'];
    fprintf(fid_channels_list,'%s\n',epoch_list_name);
    fid_epoch_list=fopen(epoch_list_name,'w');

    fieldname=char(fieldnames(9-channels(c)))
    channel_data=getfield(data,fieldname);
    channel_data=getfield(channel_data,'values');
    no_epochs=floor(length(channel_data)/epoch_length);
    
    for i=1:no_epochs
        
        epoch_data=channel_data(epoch_length*(i-1)+1:epoch_length*i);
               
        epoch_name=[writename,'_epoch',num2str(i),'.txt'];
        
        fid=fopen(epoch_name,'w');
        fprintf(fid,'%f\n',epoch_data);
        fclose(fid);
        
        fprintf(fid_epoch_list,'%s\n',epoch_name);
                
    end
            
end

cd (present_dir)
    



