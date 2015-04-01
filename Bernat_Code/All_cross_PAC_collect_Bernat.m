function All_cross_PAC_collect_Bernat(channel_label1,channels1,channel_label2,channels2)

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'saline','MK801','NVP','Ro25'};
drug_num=length(drugs);

dir = sprintf('ALL_%s_A_by_%s_P_PAC', channel_label1, channel_label2);

mkdir (dir)

drugs_fid=fopen([dir,'/',dir(1:end-4),'_drugs.txt'],'w');
subjects_fid=fopen([dir,'/',dir(1:end-4),'_subjects.txt'],'w');
hrs_fid=fopen([dir,'/',dir(1:end-4),'_hrs.txt'],'w');
fourhrs_fid = fopen([dir,'/',dir(1:end-4),'_4hrs.txt'],'w');
sixmins_fid = fopen([dir,'/',dir(1:end-4),'_6mins.txt'],'w');
states_fid=fopen([dir,'/',dir(1:end-4),'_states.txt'],'w');
PAC_fid=fopen([dir,'/',dir,'.txt'],'w');
PAC_thresh_fid=fopen([dir,'/',dir,'_thresh.txt'],'w');
PAC_zs_fid=fopen([dir,'/',dir,'_zs.txt'],'w');
PAC_pct_fid=fopen([dir,'/',dir,'_pct.txt'],'w');
PAC_thresh_pct_fid=fopen([dir,'/',dir,'_thresh_pct.txt'],'w');

for d = 1:drug_num
    
    drug = char(drugs{d});

    for s = 1:subj_num
        
        subject = char(subjects{s});
        
        channel1 = channels1(s);
        channel2 = channels2(s);
        
        record_dir = [subject,'_',drug];
        
        pair_dir = [record_dir,'_ch',num2str(channel1),'_A_by_ch',num2str(channel2),'_P_PAC'];
        
        chan1_dir = [record_dir,'_chan',num2str(channel1),'_epochs'];
        
        subj_PAC_file = [record_dir,'/',pair_dir,'/ALL_',pair_dir,'.txt'];
        subj_PAC_thresh_file = [record_dir,'/',pair_dir,'/ALL_',pair_dir,'_thresh.txt'];
        subj_hr_file = [record_dir,'/',pair_dir,'/ALL_',pair_dir(1:end-3),'_hrs.txt'];
        subj_4hr_file = [record_dir,'/',chan1_dir,'/',chan1_dir(1:end-length('epochs')),'4hrs_by_state_epochs.list'];
        subj_6min_file = [record_dir,'/',chan1_dir,'/',chan1_dir(1:end-length('epochs')),'6mins_epochs.list'];
        
        % subj_pd_fid = fopen(subj_pd_file,'r');
        % subj_pds = textscan(subj_pd_fid,'%s');
        % subj_pds = subj_pds{1};
        subj_hrs = text_read(subj_hr_file,'%s');
        [subj_4hrs, subj_states] = text_read(subj_4hr_file,'%*d%s%s%*[^\n]');
        subj_6mins = text_read(subj_6min_file,'%*d%d%*[^\n]');
        
        subj_PAC = load(subj_PAC_file);
        subj_PAC_thresh = load(subj_PAC_thresh_file);
            
        subj_PAC_zs = zscore(subj_PAC);
        
        baseline_indices = strcmp(subj_hrs,'pre4') | strcmp(subj_hrs,'pre3') | strcmp(subj_hrs,'pre2') | strcmp(subj_hrs,'pre1');
        baseline_PAC = ones(size(subj_PAC))*diag(nanmean(subj_PAC(baseline_indices,:)));
        subj_PAC_pct = 100*subj_PAC./baseline_PAC-100*ones(size(subj_PAC));
        
        baseline_PAC_thresh = ones(size(subj_PAC_thresh))*diag(nanmean(subj_PAC_thresh(baseline_indices,:)));
        subj_PAC_thresh_pct = 100*subj_PAC_thresh./baseline_PAC_thresh-100*ones(size(subj_PAC_thresh));
        
        [no_epochs, no_freq_pairs] = size(subj_PAC);
        PAC_format = make_format(no_freq_pairs, 'f');
        
        for e=1:no_epochs
            
            fprintf(drugs_fid, '%s\n', drug);
            fprintf(subjects_fid, '%s\n', subject);
            fprintf(hrs_fid, '%s\n', subj_hrs{e});
            fprintf(fourhrs_fid, '%s\n', subj_4hrs{e});
            fprintf(sixmins_fid, '%d\n', subj_6mins(e));
            fprintf(states_fid, '%s\n', subj_states{e});
            fprintf(PAC_fid, PAC_format, subj_PAC(e,:));
            fprintf(PAC_thresh_fid, PAC_format, subj_PAC_thresh(e,:));
            fprintf(PAC_zs_fid, PAC_format, subj_PAC_zs(e,:));
            fprintf(PAC_pct_fid, PAC_format, subj_PAC_pct(e,:));
            fprintf(PAC_thresh_pct_fid, PAC_format, subj_PAC_thresh_pct(e,:));
            
        end
        
    end
    
end

fclose('all');