function All_MI_collect_Bernat(measure_suffix,channel_label,channels)

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

% states={'W','NR','R'};
% no_states=length(states);

name=['ALL_',channel_label];

subjects_fid = fopen([name,'/',name,'_',measure_suffix,'_subjects.txt'],'w');
drugs_fid = fopen([name,'/',name,'_',measure_suffix,'_drugs.txt'],'w');
hr_periods_fid = fopen([name,'/',name,'_',measure_suffix,'_hr_periods.txt'],'w');
fourhr_periods_fid = fopen([name,'/',name,'_',measure_suffix,'_4hr_periods.txt'],'w');
sixmin_periods_fid = fopen([name,'/',name,'_',measure_suffix,'_6min_periods.txt'],'w');
states_fid = fopen([name,'/',name,'_',measure_suffix,'_states.txt'],'w');
MI_fid = fopen([name,'/',name,'_',measure_suffix,'_hr_MI.txt'],'w');
MI_4hr_fid = fopen([name,'/',name,'_',measure_suffix,'_4hr_MI.txt'],'w');
MI_pct_fid = fopen([name,'/',name,'_',measure_suffix,'_hr_MI_pct.txt'],'w');
MI_4hr_pct_fid = fopen([name,'/',name,'_',measure_suffix,'_4hr_MI_pct.txt'],'w');

MI_format=make_format(length(1:.25:12)*length(20:5:200),'f');

for s=1:subj_num
    
    subject=char(subjects{s});
    
    channel=channels(s);
    
    for d=1:no_drugs
        
        drug=char(drugs{d});
        
        record_dir=[subject,'_',drug];
        
        channel_name=[record_dir,'_chan',num2str(channel)];
        channel_dir=[channel_name,'_epochs'];
        
        hr_periods = text_read([record_dir,'/',channel_dir,'/',channel_name,'_hours_epochs.list'], '%*d%s%*[^\n]');
        sixmin_periods = text_read([record_dir,'/',channel_dir,'/',channel_name,'_6mins_epochs.list'], '%*d%d%*[^\n]');
        [fourhr_periods, states] = text_read([record_dir,'/',channel_dir,'/',channel_name,'_4hrs_by_state_epochs.list'], '%*d%s%s%*[^\n]');
            
        hr_data=load([record_dir,'/',channel_dir,'/ALL_',channel_name,'_hours/ALL_',channel_name,'_hours_',measure_suffix,'.txt']);
        fourhr_data=load([record_dir,'/',channel_dir,'/ALL_',channel_name,'_4hrs_by_state/ALL_',channel_name,'_4hrs_by_state_',measure_suffix,'.txt']);
        [no_epochs,~]=size(hr_periods);
        % display(sprintf('%s: length(hr_data) = %d; length(fourhr_data) = %d; no_epochs = %d.', record_dir, length(hr_data), length(fourhr_data), no_epochs))
        
        baseline_indicator = strcmp(fourhr_periods, 'pre4to1') | strcmp(fourhr_periods, 'pre8to5');
        
        baseline_hr_mean = mean(hr_data(baseline_indicator));
        baseline_4hr_mean = mean(fourhr_data(baseline_indicator));
        pct_hr_data = (hr_data./(ones(size(hr_data))*diag(baseline_hr_mean)) - ones(size(hr_data)))*100;
        pct_4hr_data = (fourhr_data./(ones(size(fourhr_data))*diag(baseline_4hr_mean)) - ones(size(fourhr_data)))*100;
        
        for e=1:no_epochs
            
            fprintf(subjects_fid, '%s\n', subject);
            
            fprintf(drugs_fid, '%s\n', drug);
            
            fprintf(hr_periods_fid, '%s\n', char(hr_periods{e}));
            
            fprintf(sixmin_periods_fid, '%d\n', sixmin_periods(e));
            
            fprintf(fourhr_periods_fid, '%s\n', char(fourhr_periods{e}));
            
            fprintf(states_fid, '%s\n', char(states{e}));
            
            fprintf(MI_fid,MI_format,hr_data(e,:));
            
            fprintf(MI_4hr_fid,MI_format,fourhr_data(e,:));
            
            fprintf(MI_pct_fid, MI_format, pct_hr_data(e,:));
            
            fprintf(MI_4hr_pct_fid, MI_format, pct_4hr_data(e,:));
            
        end
        
    end
    
end

fclose('all');