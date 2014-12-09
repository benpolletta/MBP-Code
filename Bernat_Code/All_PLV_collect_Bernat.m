function All_PLV_collect_Bernat(channel_label1,channels1,channel_label2,channels2)

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'saline','MK801','NVP','Ro25'};
drug_num=length(drugs);

dir=sprintf('ALL_%s_by_%s_PLV',channel_label1,channel_label2);

mkdir (dir)

drugs_fid=fopen([dir,'/',dir(1:end-4),'_drugs.txt'],'w');
subjects_fid=fopen([dir,'/',dir(1:end-4),'_subjects.txt'],'w');
hrs_fid=fopen([dir,'/',dir(1:end-4),'_hrs.txt'],'w');
fourhrs_fid = fopen([dir,'/',dir(1:end-4),'_4hrs.txt'],'w');
sixmins_fid = fopen([dir,'/',dir(1:end-4),'_6mins.txt'],'w');
states_fid=fopen([dir,'/',dir(1:end-4),'_states.txt'],'w');
PLV_fid=fopen([dir,'/',dir(1:end-4),'_PLV.txt'],'w');
PLV_thresh_fid=fopen([dir,'/',dir(1:end-4),'_PLV_thresh.txt'],'w');
PLV_zs_fid=fopen([dir,'/',dir(1:end-4),'_PLV_zs.txt'],'w');
PLV_pct_fid=fopen([dir,'/',dir(1:end-4),'_PLV_pct.txt'],'w');
PLV_thresh_pct_fid=fopen([dir,'/',dir(1:end-4),'_PLV_thresh_pct.txt'],'w');
PP_fid=fopen([dir,'/',dir(1:end-4),'_PP.txt'],'w');

for d = 1:drug_num
    
    drug = char(drugs{d});

    for s = 1:subj_num
        
        subject = char(subjects{s});
        
        channel1 = channels1(s);
        channel2 = channels2(s);
        
        record_dir = [subject,'_',drug];
        
        pair_dir = [record_dir,'_ch',num2str(channel1),'_by_ch',num2str(channel2),'_PLV'];
        
        chan1_dir = [record_dir,'_chan',num2str(channel1),'_epochs'];
        
        subj_PLV_file = [record_dir,'/',pair_dir,'/ALL_',pair_dir,'.txt'];
        subj_PLV_thresh_file = [record_dir,'/',pair_dir,'/ALL_',pair_dir,'_thresh.txt'];
        subj_PP_file = [record_dir,'/',pair_dir,'/ALL_',pair_dir(1:end-3),'_PP.txt'];
        subj_hr_file = [record_dir,'/',pair_dir,'/ALL_',pair_dir(1:end-3),'_hrs.txt'];
        subj_4hr_file = [record_dir,'/',chan1_dir,'/',chan1_dir(1:end-length('epochs')),'4hrs_by_state_epochs.list'];
        subj_6min_file = [record_dir,'/',chan1_dir,'/',chan1_dir(1:end-length('epochs')),'6mins_epochs.list'];
        
        % subj_pd_fid = fopen(subj_pd_file,'r');
        % subj_pds = textscan(subj_pd_fid,'%s');
        % subj_pds = subj_pds{1};
        subj_hrs = text_read(subj_hr_file,'%s');
        [subj_4hrs, subj_states] = text_read(subj_4hr_file,'%*d%s%s%*[^\n]');
        subj_6mins = text_read(subj_6min_file,'%*d%d%*[^\n]');
        
        subj_PLV = load(subj_PLV_file);
        subj_PLV_thresh = load(subj_PLV_thresh_file);
        subj_PP = load(subj_PP_file);
            
        subj_PLV_zs = zscore(subj_PLV);
        
        baseline_indices = strcmp(subj_hrs,'pre4') | strcmp(subj_hrs,'pre3') | strcmp(subj_hrs,'pre2') | strcmp(subj_hrs,'pre1');
        baseline_PLV = ones(size(subj_PLV))*diag(nanmean(subj_PLV(baseline_indices,:)));
        subj_PLV_pct = 100*subj_PLV./baseline_PLV-100*ones(size(subj_PLV));
        
        baseline_PLV_thresh = ones(size(subj_PLV_thresh))*diag(nanmean(subj_PLV_thresh(baseline_indices,:)));
        subj_PLV_thresh_pct = 100*subj_PLV_thresh./baseline_PLV_thresh-100*ones(size(subj_PLV_thresh));
        
        [no_epochs,no_freqs] = size(subj_PLV);
        PLV_format = make_format(no_freqs,'f');
        
        for e=1:no_epochs
            
            fprintf(drugs_fid,'%s\n',drug);
            fprintf(subjects_fid,'%s\n',subject);
            fprintf(hrs_fid,'%s\n',subj_hrs{e});
            fprintf(fourhrs_fid,'%s\n',subj_4hrs{e});
            fprintf(sixmins_fid,'%d\n',subj_6mins(e));
            fprintf(states_fid,'%s\n',subj_states{e});
            fprintf(PLV_fid,PLV_format,subj_PLV(e,:));
            fprintf(PLV_thresh_fid,PLV_format,subj_PLV_thresh(e,:));
            fprintf(PLV_zs_fid,PLV_format,subj_PLV_zs(e,:));
            fprintf(PLV_pct_fid,PLV_format,subj_PLV_pct(e,:));
            fprintf(PLV_thresh_pct_fid,PLV_fromat,subj_PLV_thresh_pct(e,:));
            fprintf(PP_fid,PLV_format,subj_PP(e,:));
            
        end
        
    end
    
end

fclose('all');