function All_PLV_pct_by_state(channel_label1, channel_label2)

subject_labels = {'A99','A102','A103','A104','A105','A106'};
subj_num = length(subject_labels);

drug_labels = {'saline','MK801','NVP','Ro25'};
drug_num = length(drug_labels);

state_labels = {'R','W','NR'};
no_states = length(state_labels);

dir = ['ALL_', channel_label1, '_by_', channel_label2];

drugs = text_read([dir,'_PLV/',dir,'_drugs.txt'], '%s');
subjects = text_read([dir,'_PLV/',dir,'_subjects.txt'], '%s');
fourhrs = text_read([dir,'_PLV/',dir,'_4hrs.txt'], '%s');
states = text_read([dir,'_PLV/',dir,'_states.txt'], '%s');
PLV = load([dir,'_PLV/',dir,'_PLV_thresh.txt'],'w');
summed_PLV = load([dir,'_PLV/',dir,'_PLV_summed.mat'],'summed_PLV_thresh');
summed_PLV = summed_PLV.summed_PLV_thresh;

PLV_pct = nan(size(PLV));

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
            
            % Normalizing PLV.
            
            subj_PLV_pct = PLV(subj_indices, :);
            
            baseline_PLV = ones(size(subj_PLV_pct))*diag(nanmean(PLV(subj_baseline_indices,:)));
            
            subj_PLV_pct = 100*subj_PLV_pct./baseline_PLV - 100*ones(size(subj_PLV_pct));
            
            PLV_pct(subj_indices, :) = subj_PLV_pct;
            
            % Normalizing summed PLV.
            
            subj_summed_PLV_pct = summed_PLV(subj_indices, :);
            
            baseline_summed_PLV = ones(size(subj_summed_PLV_pct))*diag(nanmean(summed_PLV(subj_baseline_indices,:)));
            
            subj_summed_PLV_pct = 100*subj_summed_PLV_pct./baseline_summed_PLV - 100*ones(size(subj_summed_PLV_pct));
            
            summed_PLV_pct(subj_indices, :) = subj_summed_PLV_pct;
            
        end
        
    end
    
end

save([dir,'_PLV/',dir,'_PLV_thresh_pct_by_state.mat'], 'PLV_pct', 'summed_PLV_pct')