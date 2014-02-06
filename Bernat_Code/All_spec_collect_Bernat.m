function All_spec_collect_Bernat(channel_label,channels)

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

drugs={'saline','MK801','NVP','Ro25'};
drug_num=length(drugs);

dir=['ALL_',channel_label];

mkdir (dir)

% drugs_fid=fopen([dir,'/',dir,'_drugs.txt'],'w');
% subjects_fid=fopen([dir,'/',dir,'_subjects.txt'],'w');
% hrs_fid=fopen([dir,'/',dir,'_hrs.txt'],'w');
% fourhrs_fid=fopen([dir,'/',dir,'_4hrs.txt'],'w');
% states_fid=fopen([dir,'/',dir,'_states.txt'],'w');
spec_fid=fopen([dir,'/',dir,'_spec.txt'],'w');
spec_pct_fid=fopen([dir,'/',dir,'_spec_pct.txt'],'w');
spec_zs_fid=fopen([dir,'/',dir,'_spec_zs.txt'],'w');

for d=1:drug_num
    
    drug=char(drugs{d});

    for s=1:subj_num
        
        subject=char(subjects{s});
        
        channel=channels(s);
        
        record_dir=[subject,'_',drug];
        
        channel_name=[record_dir,'_chan',num2str(channel)];
%         channel_dir=[channel_name,'_epochs'];
        
        all_dir=['ALL_',subject,'_chan',num2str(channel)];
        
        fourhrs=textread([all_dir,'/ALL_',channel_name,'_states_pds.txt'],'%*s%*s%s%*[^\n]');
        
        spec_mat=load([all_dir,'/ALL_',channel_name,'_spec.mat']);
        spec_data=spec_mat.spec_all;
        
        [epochs,no_freqs]=size(spec_data);
        spec_format=make_format(no_freqs,'f');
        
        [~,est_inj_epoch]=max(spec_data(:,1));
        spec_data(est_inj_epoch-10:est_inj_epoch+10,:)=nan;
        
        spec_mean=ones(epochs,no_freqs)*diag(nanmean(spec_data));
        spec_std=ones(epochs,no_freqs)*diag(nanmean(spec_data));
        spec_zs=(spec_data-spec_mean)./spec_std;
        
%         baseline_indices=strcmp(fourhrs,'pre4to1') | strcmp(fourhrs,'pre8to5');
        baseline_indices=strcmp(fourhrs,'pre4to1');
        baseline_spec=ones(epochs,no_freqs)*diag(nanmean(spec_data(baseline_indices,:)));
        spec_pct=100*spec_data./baseline_spec-100*ones(epochs,no_freqs);
        
        for e=1:epochs
            
%             fprintf(drugs_fid,'%s\n',drug);
%             
%             fprintf(subjects_fid,'%s\n',subject);
%             
%             fprintf(hrs_fid,'%s\n',char(hrs{e}));
%             
%             fprintf(fourhrs_fid,'%s\n',char(fourhrs{e}));
%             
%             fprintf(states_fid,'%s\n',char(states{e}));
            
            fprintf(spec_fid,spec_format,spec_data(e,:));
            
            fprintf(spec_pct_fid,spec_format,spec_pct(e,:));
            
            fprintf(spec_zs_fid,spec_format,spec_zs(e,:));
            
        end
        
    end
    
end

fclose('all')