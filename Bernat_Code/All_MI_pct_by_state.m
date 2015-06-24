function All_MI_pct_by_state(channel_label)

subject_labels = {'A99','A102','A103','A104','A105','A106'};
subj_num = length(subject_labels);

drug_labels = {'saline','MK801','NVP','Ro25'};
drug_num = length(drug_labels);

state_labels = {'R','W','NR'};
no_states = length(state_labels);

dir = ['ALL_',channel_label];

drugs = text_read([dir,'/',dir,'_p0.99_IEzs_drugs.txt'], '%s');
subjects = text_read([dir,'/',dir,'_p0.99_IEzs_subjects.txt'], '%s');
fourhrs = text_read([dir,'/',dir,'_p0.99_IEzs_4hr_periods.txt'], '%s');
states = text_read([dir,'/',dir,'_p0.99_IEzs_states.txt'], '%s');
MI = load([dir,'/',dir,'_p0.99_IEzs_hr_MI.txt'],'w');
load([dir,'/',dir,'_p0.99_IEzs_summed.mat'], 'summed_MI');

MI_pct = nan(size(MI));
summed_MI_pct_by_state = nan(size(summed_MI));

for st = 1:no_states
    
    state = char(state_labels{st});
    
    state_indices = strcmp(states, state);
    
    for d = 1:drug_num
        
        drug = char(drug_labels{d});
        
        drug_indices = strcmp(drugs, drug);
        
        for s = 1:subj_num
            
            subject = char(subject_labels{s});
            
            % Getting indices of interest.
            
            subj_indices = strcmp(subjects, subject) & drug_indices & state_indices;
            
            subj_baseline_indices = strcmp(fourhrs, 'pre4to1') & subj_indices;
            
            % Normalizing MI.
            
            subj_MI_pct = MI(subj_indices, :);
            
            baseline_MI = ones(size(subj_MI_pct))*diag(nanmean(MI(subj_baseline_indices, :)));
            
            subj_MI_pct = 100*subj_MI_pct./baseline_MI - 100*ones(size(subj_MI_pct));
            
            MI_pct(subj_indices, :) = subj_MI_pct;
            
            % Normalizing summed MI.
            
            subj_summed_MI_pct = summed_MI(subj_indices, :);
            
            baseline_summed_MI = ones(size(subj_summed_MI_pct))*diag(nanmean(summed_MI(subj_baseline_indices, :)));
            
            subj_summed_MI_pct = 100*subj_summed_MI_pct./baseline_summed_MI - 100*ones(size(subj_summed_MI_pct));
            
            summed_MI_pct_by_state(subj_indices, :) = subj_summed_MI_pct;
            
        end
        
    end
    
end

save([dir,'/',dir,'_p0.99_IEzs_MI_pct_by_state.mat'], 'MI_pct', 'summed_MI_pct_by_state')