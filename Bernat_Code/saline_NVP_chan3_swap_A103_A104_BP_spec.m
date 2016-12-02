function saline_NVP_chan3_swap_A103_A104_BP_spec

channel = 3;

subject_labels = {'A103','A104'};
subj_num = length(subject_labels);
subj_pairs = [1 2; 2 1]; no_subj_pairs = size(subj_pairs, 1);

drug_labels = {'saline','NVP'};
drug_num = length(drug_labels);

measures = {'_states_pds', '_BP', '_spec'}; no_measures = length(measures);

for d = 1:drug_num
    
    drug = char(drug_labels{d});

    for p = 1:no_subj_pairs
        
        clear BP_all band_limits band_labels
        
        from_subj = subject_labels{subj_pairs(p, 1)};
        
        to_subj = subject_labels{subj_pairs(p, 2)};
        
        old_filename = sprintf('ALL_%s_chan%d/ALL_%s_%s_chan%d', from_subj, channel, from_subj, drug, channel);
        
        old_flag = ['_OLD_', datestr(now, 'mm-dd-yy_HH-MM-SS')];
        
        new_filename = sprintf('ALL_%s_chan%d/ALL_%s_%s_chan%d', to_subj, channel, to_subj, drug, channel);
        
        new_flag = ['_NEW_', datestr(now, 'mm-dd-yy-HH-MM-SS')];
        
        for m = 1
            
            [fourhrs, hrs, states, sixmins] = text_read([old_filename, measures{m}, '.txt'],'%s%s%s%s%*[^\n]');
            
            fid_old = fopen([old_filename, measures{m}, old_flag, '.txt'], 'w');
            
            fid_new = fopen([new_filename, measures{m}, new_flag, '.txt'], 'w');
            
            epochs = length(fourhrs);
            
            for e = 1:epochs
                
                fprintf(fid_old, '%s%s%s%s%*[^\n]', fourhrs, hrs, states, sixmins);
                
                fprintf(fid_new, '%s%s%s%s%*[^\n]', fourhrs, hrs, states, sixmins);
                
            end
            
            fclose(fid_old);
            
            fclose(fid_new);
            
        end
        
        % for m = 2:3
        %
        %     load([old_filename, measures{m}, '.mat']);
        %
        %     save([old_filename, measures{m}, old_flag, '.mat'], 'BP_all', 'band_limits', 'band_labels')
        %
        %     save([new_filename, measures{m}, new_flag, '.mat'], 'BP_all', 'band_limits', 'band_labels')
        %
        % end
            
        end
        
    end
    
end
