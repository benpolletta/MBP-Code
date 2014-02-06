function write_epochs_Satvinder(subj_name,eeg_channel,offset,conditions,cond_flags)

% offset is a vector containing the time the scoring starts, in the
% format [seconds minutes hours days]. (I am hoping the recording start and
% the beginning of the scoring are always in the same month.)

writename=[char(subj_name),'_chan',num2str(eeg_channel)];
mkdir (writename)

[edf_filename,edf_dirname]=uigetfile('*edf',['Choose edf file for ',writename]);

[vs_filename,vs_dirname]=uigetfile('*txt',['Choose vigilance state file for ',writename]);

[header,all_data]=edfread([edf_dirname,edf_filename]);

[start_event,state,duration]=textread([vs_dirname,vs_filename],'%d%s%d');

state_var=nan(start_event(end)+duration(end)+1,1);

all_data=all_data(eeg_channel,:);
secs_per_epoch=header.duration;
sampling_rate=header.samples(eeg_channel)/secs_per_epoch;
record_start_days=str2double(header.startdate(1:2));
record_start_hours=str2double(header.starttime(1:2));
record_start_minutes=str2double(header.starttime(4:5));
record_start_seconds=str2double(header.startdate(7:8));
record_start=[record_start_seconds record_start_minutes record_start_hours record_start_days];
offset=offset-record_start;

conversion=[sampling_rate; 60; 60; 24];
conversion=cumprod(conversion);
offset=offset*conversion;

fid_epoch_list=fopen([writename,'/',writename,'_epochs.list'],'w');

fid_cond_list=fopen([writename,'/',writename,'_condition_lists.list'],'w');

no_conditions=length(conditions);

for i=1:no_conditions
    
    cond_names{i}=[writename,'_',conditions{i},'.list'];
    fid_vec(i)=fopen([writename,'/',char(cond_names{i})],'w');
    fprintf(fid_cond_list,'%s\n',char(cond_names{i}));

end

fclose(fid_cond_list);

epochs_per_minute=60/secs_per_epoch;
epochs_per_hour=60*epochs_per_minute;

for i=1:length(start_event)
    
    for j=1:duration(i)
        
        epoch_no=start_event(i)+j-1;
        
        no_hours=floor(epoch_no/epochs_per_hour);
        no_minutes=floor(mod(epoch_no,epochs_per_hour)/epochs_per_minute);
        no_secs=mod(epoch_no,epochs_per_minute)*secs_per_epoch;
        begin_index=offset+[no_secs no_minutes no_hours 0]*conversion+1;
        stop_index=offset+[no_secs+secs_per_epoch no_minutes no_hours 0]*conversion;
        data=all_data(begin_index:stop_index);
        
        epoch_name=[writename,'_epoch',num2str(epoch_no),'_',char(state(i)),'.txt'];
        fid=fopen([writename,'/',epoch_name],'w');
        fprintf(fid,'%f\n',data);
        fclose(fid);

        for k=1:no_conditions
            
            if strcmp(state(i),char(cond_flags{k}))==1
                
                fprintf(fid_vec(k),'%s\n',epoch_name);
                state_var(epoch_no+1)=k-1;
                
            end
            
        end
    
        fprintf(fid_epoch_list,'%s\t%d\n',epoch_name,state_var(epoch_no+1));
        
    end

end

plot(state_var)
set(gca,'YTick',0:no_conditions,'YTickLabel',conditions)
saveas(gcf,[subj_name,'_vs_by_epoch.fig'])

fclose('all');