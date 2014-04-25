function PLV_collect_by_subject(channels1,channels2)

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
        
        pair_dir = [record_dir,'_ch',num2str(channel1),'_by_ch',num2str(channel2),'_PLV'];
        
        subj_PLV_file = [pair_dir,'/ALL_',pair_dir,'.txt'];
        subj_PLV_thresh_file = [pair_dir,'/ALL_',pair_dir,'_thresh.txt'];
        subj_PP_file = [pair_dir,'/ALL_',pair_dir(1:end-3),'_PP.txt'];
        subj_pd_file = [pair_dir,'/ALL_',pair_dir(1:end-3),'_hrs.txt'];
        
        subj_PLV_fid = fopen(subj_PLV_file,'w');
        subj_PLV_thresh_fid = fopen(subj_PLV_thresh_file,'w');
        subj_PP_fid = fopen(subj_PP_file,'w');
        subj_pd_fid = fopen(subj_pd_file,'w');
        
        for pd = 1:no_pds
            
            pd_label = pd_labels{pd};
            
            if ~isempty(dir([pair_dir,'/',pair_dir(1:end-3),pd_label,'_PLV.mat']))
            
                load([pair_dir,'/',pair_dir(1:end-3),pd_label,'_PLV.mat'])
                
                [no_epochs,no_freqs]=size(pd_PLV);
                PLV_format=make_format(no_freqs,'f');
                
                for e = 1:no_epochs
                    
                    fprintf(subj_PLV_fid,PLV_format,pd_PLV(e,:));
                    
                    fprintf(subj_PLV_thresh_fid,PLV_format,thresh_PLV(e,:));
                    
                    fprintf(subj_PP_fid,PLV_format,pd_PP(e,:));
                    
                    fprintf(subj_pd_fid,'%s\n',pd_label);
                    
                end
                
            end
            
        end
        
        fclose(subj_PLV_fid); fclose(subj_PLV_thresh_fid); fclose(subj_PP_fid); fclose(subj_pd_fid);
        
        cd (present_dir)
        
    end
    
end