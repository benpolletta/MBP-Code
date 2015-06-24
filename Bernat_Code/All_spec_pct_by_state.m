function All_spec_pct_by_state(channel_label)

subject_labels = {'A99','A102','A103','A104','A105','A106'};
subj_num = length(subject_labels);

drug_labels = {'saline','MK801','NVP','Ro25'};
drug_num = length(drug_labels);

state_labels = {'R','W','NR'};
no_states = length(state_labels);

dir = ['ALL_',channel_label];

drugs = text_read([dir,'/',dir,'_drugs.txt'], '%s');
subjects = text_read([dir,'/',dir,'_subjects.txt'], '%s');
fourhrs = text_read([dir,'/',dir,'_4hrs.txt'], '%s');
states = text_read([dir,'/',dir,'_states.txt'], '%s');
spec = load([dir,'/',dir,'_spec.txt'],'w');
BP = load([dir,'/',dir,'_BP.txt'],'w');

spec_pct = nan(size(spec));

for st = 1:no_states
    
    state = char(state_labels{st});
    
    state_indices = strcmp(states, state);
    
    for d = 1:drug_num
        
        drug = char(drug_labels{d});
        
        drug_indices = strcmp(drugs, drug);
        
        for s = 1:subj_num
            
            subject = char(subject_labels{s});
            
            subj_indices = strcmp(subjects, subject) & drug_indices & state_indices;
            
            subj_spec_pct = spec(subj_indices, :);
            
            subj_baseline_indices = strcmp(fourhrs, 'pre4to1') & subj_indices;
            
            baseline_spec = ones(size(subj_spec_pct))*diag(nanmean(spec(subj_baseline_indices,:)));
            
            subj_spec_pct = 100*subj_spec_pct./baseline_spec-100*ones(size(subj_spec_pct));
            
            spec_pct(subj_indices, :) = subj_spec_pct;
            
        end
        
    end
    
end

save([dir,'/',dir,'_spec_pct_by_state.mat'], 'spec_pct')