function write_epochs_Bernat_single_channel_mat(subject,drug,channel)

present_dir = pwd;

epoch_length = 4096*4;

subj_name = [char(subject),'_',char(drug)];

writename = [subj_name,'_chan',num2str(channel)];

data = load([subj_name, '_chan', num2str(channel), '.mat']);
fieldname = fields(data);

mkdir (subj_name)
cd (subj_name)

fid_channels_list = fopen([subj_name,'_channels.list'],'w');

epoch_list_name = [writename,'_epochs.list'];
fprintf(fid_channels_list,'%s\n',epoch_list_name);
fid_epoch_list = fopen(epoch_list_name,'w');

channel_data = getfield(data, fieldname{:});
channel_data = getfield(channel_data, 'values');
no_epochs = floor(length(channel_data)/epoch_length);

for i = 1:no_epochs
    
    epoch_data = channel_data(epoch_length*(i-1)+1:epoch_length*i);
    
    epoch_name = [writename,'_epoch',num2str(i),'.txt'];
    
    fid = fopen(epoch_name,'w');
    fprintf(fid,'%f\n',epoch_data);
    fclose(fid);
    
    fprintf(fid_epoch_list,'%s\n',epoch_name);
    
end

cd (present_dir)
    



