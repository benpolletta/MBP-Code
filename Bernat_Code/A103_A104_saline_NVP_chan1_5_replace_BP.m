function A103_A104_saline_NVP_chan1_5_replace_BP

channel_labels = {'Frontal', 'CA1'};

channels = [1 5];

subjects={'A103','A104'};
subj_num=length(subjects);

drugs={'saline','NVP'};
drug_num=length(drugs);

for d = 1:drug_num
    
    drug = char(drugs{d});

    for s = 1:subj_num
        
        subject = char(subjects{s});
        
        channel_label = channel_labels{s};
        
        dir=['ALL_',channel_label];
        
        drugs = text_read([dir,'/',dir,'_drugs.txt'], '%s');
        subjects = text_read([dir,'/',dir,'_subjects.txt'], '%s');
        % hrs_fid=fopen([dir,'/',dir,'_hrs.txt']);
        % fourhrs_fid=fopen([dir,'/',dir,'_4hrs.txt']);
        % states_fid=fopen([dir,'/',dir,'_states.txt']);
        BP = load([dir,'/',dir,'_BP.txt']);
        BP_pct = load([dir,'/',dir,'_BP_pct.txt']);
        BP_zs = load([dir,'/',dir,'_BP_zs.txt']);
        
        save([dir,'/',dir,'_BP_OLD_',datestr(now,'mm-dd-yy_HH-MM-SS'),'.mat'], 'BP', 'BP_pct', 'BP_zs')
        
        channel = channels(s);
        
        record_dir = [subject,'_',drug];
        
        channel_name = [record_dir,'_chan',num2str(channel)];
        
        all_dir=['ALL_',subject,'_chan',num2str(channel)];
        
        fourhrs = text_read([all_dir,'/ALL_',channel_name,'_states_pds.txt'],'%*s%*s%s%*[^\n]');
        
        BP_mat = load([all_dir,'/ALL_',channel_name,'_BP.mat']);
        BP_data = BP_mat.BP_all;
       
        data_indices = strcmp(subjects, subject) & strcmp(drugs, drug);
        size(BP), sum(data_indices), size(BP_data)
        
        BP(data_indices, :) = BP_data;
        
        [epochs, no_bands] = size(BP_data);
        BP_format = make_format(no_bands, 'f');
        
        [~, est_inj_epoch] = max(BP_data(:, 1));
        BP_data(est_inj_epoch-10:est_inj_epoch+10, :) = nan;
        
        BP_mean = ones(epochs, no_bands)*diag(nanmean(BP_data));
        BP_std = ones(epochs, no_bands)*diag(nanmean(BP_data));
        BP_data_zs = (BP_data - BP_mean)./BP_std;
        BP_zs(data_indices, :) = BP_data_zs;
        
        baseline_indices = strcmp(fourhrs, 'pre4to1');
        baseline_BP = ones(epochs, no_bands)*diag(nanmean(BP_data(baseline_indices, :)));
        BP_data_pct = 100*BP_data./baseline_BP - 100*ones(epochs, no_bands);
        BP_pct(data_indices, :) = BP_data_pct;
        
    end
    
end

norms = {'', '_pct', '_zs'};

fid = nan(1, length(norms));

for n = 1:length(norms)

    fid(n) = fopen([dir,'/',dir,'_BP', norms{n}, '.txt'], 'w');

end
    
fprintf(fid(1), BP_format, BP');
fprintf(fid(2), BP_format, BP_pct');
fprintf(fid(3), BP_format, BP_zs');

fclose('all');
