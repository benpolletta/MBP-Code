function write_epochs_Bernat_single_channel(subject,drug,channel)

present_dir=pwd;

% myFolder = ['C:\Bernats Data\', subject, '_', drug, '_individual_channels'];
myFolder = [subject, '_', drug];

cd (myFolder)

%drug={'MK801','NVP','Ro25','saline'};

%no_drugs=length(drug);

% states={'R','AW','NR'};
% state_vals=[1 3 2];
% no_states=length(states);

epoch_length=4096*4;

%for d=1:no_drugs

% subj_name=fullfile(myFolder,[char(subject),'_',char(drug),'_chan',num2str(channel)]);

subj_name=[char(subject),'_',char(drug),'_chan',num2str(channel)];

data=load([subj_name,'.mat']);
fieldnames=fields(data);
% channel=length(fieldnames);

% [junk,R,W,NR]=textread([subj_name,'_VS_no_header.txt'],'%s%d%d%d%*[^\n]');
% VS=[R W NR];
% no_epochs=length(VS);

%for c=1:channel

channel_data=getfield(data,char(fieldnames(1)));
channel_data=getfield(channel_data,'values');
no_epochs=floor(length(channel_data)/epoch_length);

writename=subj_name;

mkdir (writename)

fid_epoch_list=fopen([writename,'_epochs.list'],'w');

% fid_cond_list=fopen([writename,'/',writename,'_condition_lists.list'],'w');
% 
% for i=1:no_states
% 
%     state_names{i}=[writename,'_',states{i}];
%     mkdir (char(state_names{i}))
%     fid_vec(i)=fopen([dirname,'/',char(state_names{i}),'.list'],'w');
%     fprintf(fid_cond_list,'%s\n',[char(state_names{i}),'.list']);
% 
% end
% 
% fclose(fid_cond_list);

% max_eeg=0;
% min_eeg=0;

for i=1:no_epochs

%     state_index=find(VS(i,:)==1);
% 
%     state=char(states{state_index});

    epoch_data=channel_data(epoch_length*(i-1)+1:epoch_length*i);

%     epoch_name=[writename,'_epoch',num2str(i),'_',state,'.txt'];
    epoch_name=[writename,'_epoch',num2str(i),'.txt'];

    fid=fopen(epoch_name,'w');
    fprintf(fid,'%f\n',epoch_data);
    fclose(fid);

    fprintf(fid_epoch_list,'%s\n',epoch_name);

%     state_var(i)=state_vals(state_index);
% 
%     fprintf(fid_epoch_list,'%s\t%d\n',epoch_name,state_var(i));
% 
%     max_eeg=max(max_eeg,max(epoch_data));
%     min_eeg=min(min_eeg,min(epoch_data));

end

% plot(state_var)
% set(gca,'YTick',0:no_states,'YTickLabel',states)
% saveas(gcf,[subj_name,'_VS_by_epoch.fig'])

fclose('all');

cd (present_dir)
    



