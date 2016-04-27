function collect_MI_by_whm(quantile_used, states)

load('subjects.mat'), load('AP_freqs.mat')
    
state_label = '';

if ~isempty(states)
    
    no_states = length(states);
    
    for state = 1:no_states
        
        state_label = [state_label, '_', states{state}];
        
    end
    
end

name = 'ALL_Frontal';

measure = 'p0.99_IEzs';

MI_drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
MI_subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
MI_states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
MI = load([name, '/', name, '_', measure, '_hr_MI.txt']);

delta_MI = nan(ceil(quantile_used*size(MI, 1)), size(MI, 2), 7);

median_subj_MI = nan(size(MI, 2), 7, subj_num);

MI_marker = zeros(7);

pairs = nchoosek(1:3, 2);

delta_labels = {'Low whm', 'Low shm', 'Low shm/whm', 'Low whm & shm', 'Low whm & shm/whm', 'Low shm & shm/whm', 'Low whm & shm & shm/whm'};

for s = 1:subj_num
    
    subject = subjects{s};
    
    record_dir = [subject, '_saline'];
    
    subj_MI_index = strcmp(MI_subjects, subject) & strcmp(MI_drugs, 'saline');
    
    if ~isempty(state)
       
        subj_state_index = zeros(sum(subj_MI_index), 1);
        
        for state = 1:no_states
            
            subj_state_index = subj_state_index | strcmp(MI_states(subj_MI_index), states{state});
            
        end
        
    else
        
        subj_state_index = ones(sum(subj_MI_index), 1);
        
    end
    
    clear whm shm_sum
    
    load([record_dir, '_chan1_whm.mat'])

    % whm = whm(subj_state_index);
    % 
    % shm_sum = shm_sum(subj_state_index);
    
    shm_whm_q = shm_sum./whm;
    
    low_whm_indices = whm < quantile(whm, quantile_used) & subj_state_index;
    
    low_shm_sum_indices = shm_sum < quantile(shm_sum, quantile_used) & subj_state_index;
    
    low_shm_whm_q_indices = shm_whm_q < 1.1 & subj_state_index;
    
    indices = [low_whm_indices low_shm_sum_indices low_shm_whm_q_indices];
    
    subj_MI = MI(subj_MI_index, :);
    
    for i = 1:3
        
        length_selected_MI = sum(indices(:, i));
        
        delta_MI(MI_marker(i) + (1:length_selected_MI), :, i) = subj_MI(indices(:, i), :);
        
        median_subj_MI(:, i, s) = median(subj_MI(indices(:, i), :))';
        
        MI_marker(i) = MI_marker(i) + length_selected_MI;
        
    end
    
    for p = 1:3
        
        index = indices(:, pairs(p, 1)) & indices(:, pairs(p, 2));
        
        length_selected_MI = sum(index);
        
        delta_MI(MI_marker(3 + p) + (1:length_selected_MI), :, 3 + p) = subj_MI(index, :);
        
        median_subj_MI(:, 3 + p, s) = median(subj_MI(index, :))';
        
        MI_marker(3 + p) = MI_marker(3 + p) + length_selected_MI;
        
    end
    
    index = cumprod(indices, 2); index = logical(index(:, 3));
    
    length_selected_MI = sum(index);
    
    delta_MI(MI_marker(7) + (1:length_selected_MI), :, 7) = subj_MI(index, :);
        
    median_subj_MI(:, 7, s) = median(subj_MI(index, :))';
    
    MI_marker(7) = MI_marker(7) + length_selected_MI;
    
end

median_MI = nan(size(MI, 2), 7);

for i = 1:7
    
    median_MI(:, i) = nanmedian(delta_MI(:, :, i))';
    
end

save(['delta_MI_q', num2str(quantile_used), state_label, '.mat'], 'state', 'quantile_used', 'delta_MI', 'median_subj_MI', 'median_MI')