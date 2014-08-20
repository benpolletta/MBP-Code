function All_summed_MI_normalize_Bernat(channel_label, measure)

subject_names={'A99','A102','A103','A104','A105','A106'};
no_subjects=length(subject_names);

drug_labels={'saline','MK801','NVP','Ro25'};
no_drugs=length(drug_labels);

name=['ALL_',channel_label];

drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
fourhrs = text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
load([name,'/',name,'_',measure,'_summed.mat']);

summed_MI_pct = nan(size(summed_MI));

for s = 1:no_subjects
    
    for d = 1:no_drugs
        
        record_indices = strcmp(drugs,drug_labels{d}) & strcmp(subjects,subject_names{s});
        
        record_MI = summed_MI(record_indices, :);
        
        record_4hr_periods = fourhrs(record_indices);
        
        baseline_indices = strcmp(record_4hr_periods,'pre8to5') | strcmp(record_4hr_periods,'pre4to1');
        
        baseline_mean = ones(size(record_MI))*diag(nanmean(record_MI(baseline_indices, :)));
        
        pct_MI = 100*(record_MI - baseline_mean)./baseline_mean - 100*ones(size(record_MI));
       
        summed_MI_pct(record_indices, :) = pct_MI;

    end
    
end

save([name,'/',name,'_',measure,'_summed_pct.mat'], 'summed_MI_pct')



