function collect_MI_by_whm_matched(drug, quantile_used, shm_lim, states)

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
non_delta_MI = nan(ceil((1 - quantile_used)*size(MI, 1)), size(MI, 2), 7);

[median_subj_dMI, median_subj_ndMI] = deal(nan(size(MI, 2), 7, subj_num));

dMI_marker = zeros(7);

pairs = nchoosek(1:3, 2);

for s = 1:subj_num
    
    subject = subjects{s};
    
    record_dir = [subject, '_', drug];
    
    subj_MI_index = strcmp(MI_subjects, subject) & strcmp(MI_drugs, drug);
    
    if ~isempty(states)
       
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
    
    if length(whm) > length(subj_state_index)
        
        whm((length(subj_state_index) + 1):end) = [];
        
        shm_sum((length(subj_state_index) + 1):end) = [];
        
    end
    
    shm_whm_q = shm_sum./whm;
    
    low_whm_indices = whm < quantile(whm, quantile_used) & subj_state_index;
    
    low_shm_sum_indices = shm_sum < quantile(shm_sum, quantile_used) & subj_state_index;
    
    low_shm_whm_q_indices = shm_whm_q < shm_lim & subj_state_index;
    
    indices = [low_whm_indices low_shm_sum_indices low_shm_whm_q_indices];
    
    high_whm_indices = whm >= quantile(whm, quantile_used) & subj_state_index;
    
    high_shm_sum_indices = shm_sum >= quantile(shm_sum, quantile_used) & subj_state_index;
    
    high_shm_whm_q_indices = shm_whm_q >= shm_lim & subj_state_index;
    
    non_indices = [high_whm_indices high_shm_sum_indices high_shm_whm_q_indices];
    
    subj_MI = MI(subj_MI_index, :);
    
    for i = 1:3
        
        length_selected_dMI = sum(indices(:, i));
        
        delta_MI(dMI_marker(i) + (1:length_selected_dMI), :, i) = subj_MI(indices(:, i), :);
        
        median_subj_dMI(:, i, s) = median(subj_MI(indices(:, i), :))';
        
        dMI_marker(i) = dMI_marker(i) + length_selected_dMI;
        
        non_delta_index = find(non_indices(:, i));
        
        chosen_indices = randperm(length(non_delta_index));
        
        chosen_indices((length_selected_dMI + 1):end) = [];
        
        non_delta_MI(dMI_marker(i) + (1:length_selected_dMI), :, i) = subj_MI(chosen_indices, :);
        
        median_subj_ndMI(:, i, s) = median(subj_MI(chosen_indices, :))';
        
    end
    
    for p = 1:3
        
        index = indices(:, pairs(p, 1)) & indices(:, pairs(p, 2));
        
        length_selected_dMI = sum(index);
        
        delta_MI(dMI_marker(3 + p) + (1:length_selected_dMI), :, 3 + p) = subj_MI(index, :);
        
        median_subj_dMI(:, 3 + p, s) = median(subj_MI(index, :))';
        
        dMI_marker(3 + p) = dMI_marker(3 + p) + length_selected_dMI;
        
        non_index = non_indices(:, pairs(p, 1)) | non_indices(:, pairs(p, 2));
        
        non_delta_index = find(non_index);
        
        chosen_indices = randperm(length(non_delta_index));
        
        chosen_indices((length_selected_dMI + 1):end) = [];
        
        non_delta_MI(dMI_marker(3 + p) + (1:length_selected_dMI), :, 3 + p) = subj_MI(chosen_indices, :);
        
        median_subj_ndMI(:, 3 + p, s) = median(subj_MI(chosen_indices, :))';
        
    end
    
    index = cumprod(indices, 2); index = logical(index(:, 3));
    
    non_index = sum(non_indices, 2) > 0;
    
    length_selected_dMI = sum(index);
    
    delta_MI(dMI_marker(7) + (1:length_selected_dMI), :, 7) = subj_MI(index, :);
        
    median_subj_dMI(:, 7, s) = median(subj_MI(index, :))';
    
    dMI_marker(7) = dMI_marker(7) + length_selected_dMI;
    
    non_delta_index = find(non_index);
    
    chosen_indices = randperm(length(non_delta_index));
    
    chosen_indices((length_selected_dMI + 1):end) = [];
    
    non_delta_MI(dMI_marker(7) + (1:length_selected_dMI), :, 7) = subj_MI(chosen_indices, :);
        
    median_subj_ndMI(:, 7, s) = median(subj_MI(chosen_indices, :))';
    
end

[median_dMI, median_ndMI] = deal(nan(size(MI, 2), 7));

for i = 1:7
    
    median_dMI(:, i) = nanmedian(delta_MI(:, :, i))';
    
    median_ndMI(:, i) = nanmedian(non_delta_MI(:, :, i))';
    
end

save([drug, '_delta_MI_q', num2str(quantile_used), '_shm', num2str(shm_lim), state_label, '_matched.mat'], '-v7.3',...
    'drug', 'shm_lim', 'state', 'quantile_used', 'delta_MI', 'median_subj_dMI', 'median_dMI',...
    'non_delta_MI', 'median_subj_ndMI', 'median_ndMI')