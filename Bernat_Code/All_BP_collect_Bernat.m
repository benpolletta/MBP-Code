function All_BP_collect_Bernat(channel_label,channels)

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'saline','MK801','NVP','Ro25'};
drug_num=length(drugs);

dir=['ALL_',channel_label];

mkdir (dir)

drugs_fid=fopen([dir,'/',dir,'_drugs.txt'],'w');
subjects_fid=fopen([dir,'/',dir,'_subjects.txt'],'w');
hrs_fid=fopen([dir,'/',dir,'_hrs.txt'],'w');
fourhrs_fid=fopen([dir,'/',dir,'_4hrs.txt'],'w');
states_fid=fopen([dir,'/',dir,'_states.txt'],'w');
BP_fid=fopen([dir,'/',dir,'_BP.txt'],'w');
BP_pct_fid=fopen([dir,'/',dir,'_BP_pct.txt'],'w');
BP_zs_fid=fopen([dir,'/',dir,'_BP_zs.txt'],'w');

for d=1:drug_num
    
    drug=char(drugs{d});

    for s=1:subj_num
        
        subject=char(subjects{s});
        
        channel=channels(s);
        
        record_dir=[subject,'_',drug];
        
        channel_name=[record_dir,'_chan',num2str(channel)];
%         channel_dir=[channel_name,'_epochs'];
        
        all_dir=['ALL_',subject,'_chan',num2str(channel)];
        
        [states,hrs,fourhrs]=textread([all_dir,'/ALL_',channel_name,'_states_pds.txt'],'%s%s%s%*[^\n]');
        
        BP_mat=load([all_dir,'/ALL_',channel_name,'_BP.mat']);
        BP_data=BP_mat.BP_all;
        
        [epochs,no_bands]=size(BP_data);
        BP_format=make_format(no_bands,'f');
        
        [~,est_inj_epoch]=max(BP_data(:,1));
        BP_data(est_inj_epoch-10:est_inj_epoch+10,:)=nan;
        
        BP_mean=ones(epochs,no_bands)*diag(nanmean(BP_data));
        BP_std=ones(epochs,no_bands)*diag(nanmean(BP_data));
        BP_zs=(BP_data-BP_mean)./BP_std;
        
%         baseline_indices=strcmp(fourhrs,'pre4to1') | strcmp(fourhrs,'pre8to5');
        baseline_indices=strcmp(fourhrs,'pre4to1');
        baseline_BP=ones(epochs,no_bands)*diag(nanmean(BP_data(baseline_indices,:)));
        BP_pct=100*BP_data./baseline_BP-100*ones(epochs,no_bands);
        
        for e=1:epochs
            
            fprintf(drugs_fid,'%s\n',drug);
            
            fprintf(subjects_fid,'%s\n',subject);
            
            fprintf(hrs_fid,'%s\n',char(hrs{e}));
            
            fprintf(fourhrs_fid,'%s\n',char(fourhrs{e}));
            
            fprintf(states_fid,'%s\n',char(states{e}));
            
            fprintf(BP_fid,BP_format,BP_data(e,:));
            
            fprintf(BP_pct_fid,BP_format,BP_pct(e,:));
            
            fprintf(BP_zs_fid,BP_format,BP_zs(e,:));
            
        end
        
    end
    
end

fclose('all')