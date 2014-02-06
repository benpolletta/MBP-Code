function [max_eeg,min_eeg]=write_epochs_Heinrich(subj_name,eeg_channel,emg_channel,hires,secs_per_epoch,offset,conditions,cond_flags)

writename=[char(subj_name),'_chan',num2str(eeg_channel)];
mkdir (writename)

[hea_filename,hea_dirname]=uigetfile('*hea',['Choose header file for ',writename])

[vs_filename,vs_dirname]=uigetfile('*txt',['Choose vigilance state file for ',writename])
[start_event,state,duration]=textread([vs_dirname,vs_filename],'%d%s%d');

% conditions={'epochs','Wake','NREM','REM','M'};

state_var=nan(start_event(end)+duration(end)+1,1);

fid_epoch_list=fopen([writename,'\',writename,'_epochs.list'],'w');

fid_cond_list=fopen([writename,'\',writename,'_condition_lists.list'],'w');

no_conditions=length(conditions);

for i=1:no_conditions
    
    cond_names{i}=[writename,'_',conditions{i},'.list'];
    fid_vec(i)=fopen([writename,'\',char(cond_names{i})],'w');
    fprintf(fid_cond_list,'%s\n',char(cond_names{i}));

end

fclose(fid_cond_list);

epochs_per_minute=60/secs_per_epoch;
epochs_per_hour=60*epochs_per_minute;

max_eeg=0;
min_eeg=0;

for i=1:length(start_event)
    
    for j=1:duration(i)
        
        epoch_no=start_event(i)+j-1;
        
        no_hours=offset(1)+floor(epoch_no/epochs_per_hour);
        no_minutes=offset(2)+floor(mod(epoch_no,epochs_per_hour)/epochs_per_minute);
        no_secs=offset(3)+mod(epoch_no,epochs_per_minute)*secs_per_epoch;
        begin_time=[num2str(no_hours),':',num2str(no_minutes),':',num2str(no_secs)];
        stop_time=[num2str(no_hours),':',num2str(no_minutes),':',num2str(no_secs+secs_per_epoch)];
        if hires==0
            data=rdsamp(hea_filename,'begin',begin_time,'stop',stop_time,'sigs',eeg_channel-1,emg_channel-1);
        else
            data=rdsamp(hea_filename,'begin',begin_time,'stop',stop_time,'hires',true,'sigs',eeg_channel-1,emg_channel-1);
        end
%         [r,c]=size(data);
%         format=make_format(c,'f');

        epoch_name=[writename,'_epoch',num2str(epoch_no),'_',char(state(i)),'_emg.txt'];
        fid=fopen([writename,'\',epoch_name],'w');
        fprintf(fid,'%f\t%f\n',data(:,2:3)');
        fclose(fid);


        max_eeg=max(max_eeg,max(data(:,2)));
        min_eeg=min(min_eeg,min(data(:,2)));
        
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