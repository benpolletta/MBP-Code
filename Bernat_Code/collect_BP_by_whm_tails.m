function collect_BP_by_whm_tails(drug, quantile_used, shm_lims, states)

load('subjects.mat'), load('AP_freqs.mat')
    
state_label = '';

if ~isempty(states)
    
    no_states = length(states);
    
    for state = 1:no_states
        
        state_label = [state_label, '_', states{state}];
        
    end
    
end

name = 'ALL_Frontal';

BP_drugs = text_read([name,'/',name,'_drugs.txt'],'%s');
BP_subjects = text_read([name,'/',name,'_subjects.txt'],'%s');
BP_states = text_read([name,'/',name,'_states.txt'],'%s');
BP = load([name, '/', name, '_BP_pct.txt']);

no_criteria = 4;
no_pairs = nchoosek(no_criteria, 2);
no_figures = no_criteria + no_pairs + 1;

delta_BP = nan(ceil(quantile_used*size(BP, 1)), size(BP, 2), no_figures);
non_delta_BP = nan(ceil((1 - quantile_used)*size(BP, 1)), size(BP, 2), no_figures);

[median_subj_dBP, median_subj_ndBP] = deal(nan(size(BP, 2), no_figures, subj_num));

[dBP_marker, ndBP_marker] = deal(zeros(no_figures, 1));

indices = cell(subj_num, 2);

pairs = nchoosek(1:no_criteria, 2);

delta_labels = {'Low whm', 'Low shm', 'Low shm/whm', 'Low whm & shm', 'Low whm & shm/whm', 'Low shm & shm/whm', 'Low whm & shm & shm/whm'};

for s = 1:subj_num
    
    subject = subjects{s};
    
    record_dir = [subject, '_', drug];
    
    subj_BP_index = strcmp(BP_subjects, subject) & strcmp(BP_drugs, drug);
    
    if ~isempty(states)
       
        subj_state_index = zeros(sum(subj_BP_index), 1);
        
        for state = 1:no_states
            
            subj_state_index = subj_state_index | strcmp(BP_states(subj_BP_index), states{state});
            
        end
        
    else
        
        subj_state_index = ones(sum(subj_BP_index), 1);
        
    end
    
    clear whm shm_sum entropy
    
    load([record_dir, '_chan1_whm.mat'])

    % whm = whm(subj_state_index);
    % 
    % shm_sum = shm_sum(subj_state_index);
    
    if length(whm) > length(subj_state_index)
        
        whm((length(subj_state_index) + 1):end) = [];
        
        shm_sum((length(subj_state_index) + 1):end) = [];
        
        entropy((length(subj_state_index) + 1):end) = [];
        
    end
    
    shm_whm_q = shm_sum./whm;
    
    low_whm_indices = whm < quantile(whm, quantile_used) & subj_state_index;
    
    low_shm_sum_indices = shm_sum < quantile(shm_sum, quantile_used) & subj_state_index;
    
    low_shm_whm_q_indices = shm_whm_q < shm_lims(1) & subj_state_index;
    
    low_entropy_indices = entropy < quantile(entropy, quantile_used) & subj_state_index;
    
    subj_indices = [low_whm_indices low_shm_sum_indices low_shm_whm_q_indices low_entropy_indices];
    
    high_whm_indices = whm > quantile(whm, 1 - quantile_used) & subj_state_index;
    
    high_shm_sum_indices = shm_sum > quantile(shm_sum, 1 - quantile_used) & subj_state_index;
    
    high_shm_whm_q_indices = shm_whm_q > shm_lims(2) & subj_state_index;
    
    high_entropy_indices = entropy > quantile(entropy, 1 - quantile_used) & subj_state_index;
    
    subj_non_indices = [high_whm_indices high_shm_sum_indices high_shm_whm_q_indices high_entropy_indices];
    
    subj_MI = BP(subj_BP_index, :);
    
    for c = 1:no_criteria
        
        length_selected_dMI = sum(subj_indices(:, c));
        
        delta_BP(dBP_marker(c) + (1:length_selected_dMI), :, c) = subj_MI(subj_indices(:, c), :);
        
        median_subj_dBP(:, c, s) = nanmedian(subj_MI(subj_indices(:, c), :))';
        
        dBP_marker(c) = dBP_marker(c) + length_selected_dMI;
        
        length_selected_ndMI = sum(subj_non_indices(:, c));
        
        non_delta_BP(ndBP_marker(c) + (1:length_selected_ndMI), :, c) = subj_MI(subj_non_indices(:, c), :);
        
        median_subj_ndBP(:, c, s) = nanmedian(subj_MI(subj_non_indices(:, c), :))';
        
        ndBP_marker(c) = ndBP_marker(c) + length_selected_ndMI;
        
    end
    
    for p = 1:no_pairs
        
        index = subj_indices(:, pairs(p, 1)) & subj_indices(:, pairs(p, 2));
        
        subj_indices(:, no_criteria + p) = index;
        
        length_selected_dMI = sum(index);
        
        delta_BP(dBP_marker(no_criteria + p) + (1:length_selected_dMI), :, no_criteria + p) = subj_MI(index, :);
        
        median_subj_dBP(:, no_criteria + p, s) = nanmedian(subj_MI(index, :))';
        
        dBP_marker(no_criteria + p) = dBP_marker(no_criteria + p) + length_selected_dMI;
        
        non_index = subj_non_indices(:, pairs(p, 1)) & subj_non_indices(:, pairs(p, 2));
        
        subj_non_indices(:, no_criteria + p) = non_index;
        
        length_selected_ndMI = sum(non_index);
        
        non_delta_BP(ndBP_marker(no_criteria + p) + (1:length_selected_ndMI), :, no_criteria + p) = subj_MI(non_index, :);
        
        median_subj_ndBP(:, no_criteria + p, s) = nanmedian(subj_MI(non_index, :))';
        
        ndBP_marker(no_criteria + p) = ndBP_marker(no_criteria + p) + length_selected_ndMI;
        
    end
    
    index = cumprod(subj_indices, 2); index = logical(index(:, end));
    
    subj_indices(:, no_criteria + no_pairs + 1) = index;
    
    length_selected_dMI = sum(index);
    
    delta_BP(dBP_marker(no_figures) + (1:length_selected_dMI), :, no_figures) = subj_MI(index, :);
        
    median_subj_dBP(:, no_figures, s) = nanmedian(subj_MI(index, :))';
    
    dBP_marker(no_figures) = dBP_marker(no_figures) + length_selected_dMI;
    
    non_index = cumprod(subj_non_indices, 2); non_index = logical(non_index(:, 3));
    
    subj_non_indices(:, no_criteria + no_pairs + 1) = index;
    
    length_selected_ndMI = sum(non_index);
    
    non_delta_BP(ndBP_marker(no_figures) + (1:length_selected_ndMI), :, no_figures) = subj_MI(non_index, :);
        
    median_subj_ndBP(:, no_figures, s) = nanmedian(subj_MI(non_index, :))';
    
    ndBP_marker(no_figures) = ndBP_marker(no_figures) + length_selected_ndMI;
    
    indices{s, 1} = subj_indices; indices{s, 2} = subj_non_indices;
    
end

% end_dMI_marker = max(dMI_marker)
% 
% end_ndMI_marker = max(ndMI_marker)
% 
% delta_MI((end_dMI_marker + 1):end, :, :) = [];
% 
% non_delta_MI((end_ndMI_marker + 1):end, :, :) = [];

[median_dMI, median_ndMI] = deal(nan(size(BP, 2), no_figures));

for f = 1:no_figures

    delta_BP(sum(delta_BP(:, :, f), 2) == 0, :, f) = nan;
    
    median_dMI(:, f) = nanmedian(delta_BP(:, :, f))';

    non_delta_BP(sum(non_delta_BP(:, :, f), 2) == 0, :, f) = nan;
    
    median_ndMI(:, f) = nanmedian(non_delta_BP(:, :, f))';
    
end

save([drug, '_delta_BP_q', num2str(quantile_used), '_shm', sprintf('%.03f_%.03f', shm_lims), state_label, '_tails.mat'], '-v7.3',...
    'drug', 'shm_lims', 'state', 'quantile_used', 'indices', 'delta_MI', 'median_subj_dMI', 'median_dMI',...
    'non_delta_MI', 'median_subj_ndMI', 'median_ndMI')