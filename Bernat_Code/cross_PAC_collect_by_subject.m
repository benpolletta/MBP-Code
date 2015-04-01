function cross_PAC_collect_by_subject(channels1,channels2)

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'saline','MK801','NVP','Ro25'};
drug_num=length(drugs);

[pd_labels,~] = make_period_labels(7,30,'hrs');

no_pds = length(pd_labels);

present_dir = pwd;

for d = 1:drug_num
    
    drug = char(drugs{d});

    for s = 1:subj_num
        
        subject = char(subjects{s});
        
        channel1 = channels1(s);
        channel2 = channels2(s);
        
        record_dir = [subject,'_',drug];
        
        cd (record_dir)
        
        pair_dir = sprintf('%s_ch%d_A_by_ch%d_P_PAC', record_dir, channel1, channel2);
        
        subj_PAC_file = [pair_dir,'/ALL_',pair_dir,'.txt'];
        subj_PAC_thresh_file = [pair_dir,'/ALL_',pair_dir,'_thresh.txt'];
        subj_pd_file = [pair_dir,'/ALL_',pair_dir(1:end-3),'_hrs.txt'];
        
        subj_PAC_fid = fopen(subj_PAC_file,'w');
        subj_PAC_thresh_fid = fopen(subj_PAC_thresh_file,'w');
        subj_pd_fid = fopen(subj_pd_file,'w');
        
        for pd = 1:no_pds
            
            pd_label = pd_labels{pd};
            
            if ~isempty(dir([pair_dir,'/',pair_dir(1:end-3),pd_label,'_PAC.mat']))
            
                load([pair_dir,'/',pair_dir(1:end-3),pd_label,'_PAC.mat'])
                
                [no_epochs, no_freq_pairs] = size(pd_MI);
                MI_format = make_format(no_freq_pairs, 'f');
                
                for e = 1:no_epochs
                    
                    fprintf(subj_PAC_fid, MI_format, pd_MI(e,:));
                    
                    fprintf(subj_PAC_thresh_fid, MI_format, thresh_MI(e,:));
                    
                    fprintf(subj_pd_fid, '%s\n', pd_label);
                    
                end
                
            end
            
        end
        
        fclose(subj_PAC_fid); fclose(subj_PAC_thresh_fid); fclose(subj_pd_fid);
        
        cd (present_dir)
        
    end
    
end