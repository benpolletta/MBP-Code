function All_AVP_collect_Bernat(phase_freq,channel_label,channels,norm_flag)

amp_freqs=20:5:200;
phase_freqs=1:.25:12;
phase_index=find(min(abs(phase_freqs-phase_freq)));
phase_bins=-0.95:.1:.95;

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

states={'W','NR','R'};
no_states=length(states);

name=['ALL_',channel_label];

subjects_fid=fopen([name,'/',name,'_AVP_p',num2str(phase_freq),'_subjects.txt'],'w');
drugs_fid=fopen([name,'/',name,'_AVP_p',num2str(phase_freq),'_drugs.txt'],'w');
hr_periods_fid=fopen([name,'/',name,'_AVP_p',num2str(phase_freq),'_hr_periods.txt'],'w');
fourhr_periods_fid=fopen([name,'/',name,'_AVP_p',num2str(phase_freq),'_4hr_periods.txt'],'w');
states_fid=fopen([name,'/',name,'_AVP_p',num2str(phase_freq),'_states.txt'],'w');

if norm_flag==1
    
    AVP_fid=fopen([name,'/',name,'_AVP_p',num2str(phase_freq),'_norm.txt'],'w');
    
elseif norm_flag==0
    
    AVP_fid=fopen([name,'/',name,'_AVP_p',num2str(phase_freq),'.txt'],'w');

else
    
    display('norm_flag must be zero or one.')
    
    return
    
end

AVP_format=make_format(length(amp_freqs)*length(phase_bins),'f');

for s=1:subj_num
    
    subject=char(subjects{s});
    
    channel=channels(s);
    
    for d=1:no_drugs
        
        drug=char(drugs{d});
        
        record_dir=[subject,'_',drug];
        
        channel_name=[record_dir,'_chan',num2str(channel)];
        channel_dir=[channel_name,'_epochs'];
        
        hr_periods=textread([record_dir,'/',channel_dir,'/',channel_name,'_hours_epochs.list'],'%*d%s%*[^\n]');
        [fourhr_periods,states]=textread([record_dir,'/',channel_dir,'/',channel_name,'_4hrs_by_state_epochs.list'],'%*d%s%s%*[^\n]');
        
        if norm_flag==1
            
            AVP_data=load([record_dir,'/',channel_dir,'/ALL_',channel_name,'_hours/ALL_',channel_name,'_hours_AVP_p',num2str(phase_freq),'_norm.txt']);
            
        elseif norm_flag==0
            
            AVP_data=load([record_dir,'/',channel_dir,'/ALL_',channel_name,'_hours/ALL_',channel_name,'_hours_AVP_p',num2str(phase_freq),'.txt']);
        
        else
        
            display('norm_flag must be zero or one.')
            
            return
            
        end
        
        no_epochs=size(AVP_data,1);
        
        for e=1:no_epochs
            
            fprintf(subjects_fid,'%s\n',subject);
            
            fprintf(drugs_fid,'%s\n',drug);
            
            fprintf(hr_periods_fid,'%s\n',char(hr_periods{e}));
            
            fprintf(fourhr_periods_fid,'%s\n',char(fourhr_periods{e}));
            
            fprintf(states_fid,'%s\n',char(states{e}));
            
            fprintf(AVP_fid,AVP_format,AVP_data(e,:));
            
        end
        
    end
    
end

fclose('all');