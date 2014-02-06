function All_MI_collect_Bernat(measure_suffix,channel_label,channels)

present_dir=pwd;

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

states={'W','NR','R'};
no_states=length(states);

name=['ALL_',channel_label];

subjects_fid=fopen([name,'/',name,'_',measure_suffix,'_subjects.txt'],'w');
drugs_fid=fopen([name,'/',name,'_',measure_suffix,'_drugs.txt'],'w');
hr_periods_fid=fopen([name,'/',name,'_',measure_suffix,'_hr_periods.txt'],'w');
fourhr_periods_fid=fopen([name,'/',name,'_',measure_suffix,'_4hr_periods.txt'],'w');
states_fid=fopen([name,'/',name,'_',measure_suffix,'_states.txt'],'w');
MI_fid=fopen([name,'/',name,'_',measure_suffix,'_hr_MI.txt'],'w');
MI_4hr_fid=fopen([name,'/',name,'_',measure_suffix,'_4hr_MI.txt'],'w');

MI_format=make_format(length(1:.25:12)*length(20:5:200),'f');

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
        
        hr_data=load([record_dir,'/',channel_dir,'/ALL_',channel_name,'_hours/ALL_',channel_name,'_hours_',measure_suffix,'.txt']);
        fourhr_data=load([record_dir,'/',channel_dir,'/ALL_',channel_name,'_4hrs_by_state/ALL_',channel_name,'_4hrs_by_state_',measure_suffix,'.txt']);
        [no_epochs,~]=size(hr_data);
        
        for e=1:no_epochs
            
            fprintf(subjects_fid,'%s\n',subject);
            
            fprintf(drugs_fid,'%s\n',drug);
            
            fprintf(hr_periods_fid,'%s\n',char(hr_periods{e}));
            
            fprintf(fourhr_periods_fid,'%s\n',char(fourhr_periods{e}));
            
            fprintf(states_fid,'%s\n',char(states{e}));
            
            fprintf(MI_fid,MI_format,hr_data(e,:));
            
            fprintf(MI_4hr_fid,MI_format,fourhr_data(e,:));
            
        end
        
    end
    
end

fclose('all');