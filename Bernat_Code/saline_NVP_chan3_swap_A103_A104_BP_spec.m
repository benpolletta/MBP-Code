function saline_NVP_chan3_swap_A103_A104_BP_spec

channel = 3;

subject_labels = {'A103','A104'};
subj_num = length(subject_labels);
subj_pairs = nchoosek(1:subj_num, 2); no_subj_pairs = size(subj_pairs, 1);

drug_labels = {'saline','NVP'};
drug_num = length(drug_labels);

measures = {'BP', 'spec'}; no_measures = length(measures);

for d = 1:drug_num
    
    drug = char(drug_labels{d});

    for p = 1:no_subj_pairs
        
        clear BP_all band_limits band_labels
        
        from_subj = subject_labels{subj_pairs(p, 1)};
        
        to_subj = subject_labels{subj_pairs(p, 1)};
        
        for m = 1:no_measures
            
            old_filename = sprintf('ALL_%s_chan%d/ALL_%s_%s_chan%d_%s', from_subj, channel, from_subj, drug, channel, measures{m});
            
            new_filename = sprintf('ALL_%s_chan%d/ALL_%s_%s_chan%d_%s', to_subj, channel, to_subj, drug, channel, measures{m});
            
            load([old_filename, '.mat']);
            
            save([old_filename, '_OLD_', datestr(now, 'mm-dd-yy_HH-MM-SS'), '.mat'], 'BP_all', 'band_limits', 'band_labels')
            
            save([new_filename, '_NEW_', datestr(now, 'mm-dd-yy-HH-MM-SS'), '.mat'], 'BP_all', 'band_limits', 'band_labels')
            
        end
        
    end
    
end
