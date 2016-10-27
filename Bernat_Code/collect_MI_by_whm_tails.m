function collect_MI_by_whm_tails(drug, quantile_used, shm_lims, states)

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

no_criteria = 4;
no_pairs = nchoosek(no_criteria, 2);
no_figures = no_criteria + no_pairs + 1;

delta_MI = nan(ceil(quantile_used*size(MI, 1)), size(MI, 2), no_figures);
non_delta_MI = nan(ceil((1 - quantile_used)*size(MI, 1)), size(MI, 2), no_figures);

[median_subj_dMI, median_subj_ndMI] = deal(nan(size(MI, 2), no_figures, subj_num));

[dMI_marker, ndMI_marker] = deal(zeros(no_figures, 1));

pairs = nchoosek(1:no_criteria, 2);

delta_labels = {'Low whm', 'Low shm', 'Low shm/whm', 'Low whm & shm', 'Low whm & shm/whm', 'Low shm & shm/whm', 'Low whm & shm & shm/whm'};

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
    
    indices = [low_whm_indices low_shm_sum_indices low_shm_whm_q_indices low_entropy_indices];
    
    high_whm_indices = whm > quantile(whm, 1 - quantile_used) & subj_state_index;
    
    high_shm_sum_indices = shm_sum > quantile(shm_sum, 1 - quantile_used) & subj_state_index;
    
    high_shm_whm_q_indices = shm_whm_q > shm_lims(2) & subj_state_index;
    
    high_entropy_indices = entropy > quantile(entropy, 1 - quantile_used) & subj_state_index;
    
    non_indices = [high_whm_indices high_shm_sum_indices high_shm_whm_q_indices high_entropy_indices];
    
    subj_MI = MI(subj_MI_index, :);
    
    for c = 1:no_criteria
        
        length_selected_dMI = sum(indices(:, c));
        
        delta_MI(dMI_marker(c) + (1:length_selected_dMI), :, c) = subj_MI(indices(:, c), :);
        
        median_subj_dMI(:, c, s) = nanmedian(subj_MI(indices(:, c), :))';
        
        dMI_marker(c) = dMI_marker(c) + length_selected_dMI;
        
        length_selected_ndMI = sum(non_indices(:, c));
        
        non_delta_MI(ndMI_marker(c) + (1:length_selected_ndMI), :, c) = subj_MI(non_indices(:, c), :);
        
        median_subj_ndMI(:, c, s) = nanmedian(subj_MI(non_indices(:, c), :))';
        
        ndMI_marker(c) = ndMI_marker(c) + length_selected_ndMI;
        
    end
    
    for p = 1:no_pairs
        
        index = indices(:, pairs(p, 1)) & indices(:, pairs(p, 2));
        
        length_selected_dMI = sum(index);
        
        delta_MI(dMI_marker(no_criteria + p) + (1:length_selected_dMI), :, no_criteria + p) = subj_MI(index, :);
        
        median_subj_dMI(:, no_criteria + p, s) = nanmedian(subj_MI(index, :))';
        
        dMI_marker(no_criteria + p) = dMI_marker(no_criteria + p) + length_selected_dMI;
        
        non_index = non_indices(:, pairs(p, 1)) & non_indices(:, pairs(p, 2));
        
        length_selected_ndMI = sum(non_index);
        
        non_delta_MI(ndMI_marker(no_criteria + p) + (1:length_selected_ndMI), :, no_criteria + p) = subj_MI(non_index, :);
        
        median_subj_ndMI(:, no_criteria + p, s) = nanmedian(subj_MI(non_index, :))';
        
        ndMI_marker(no_criteria + p) = ndMI_marker(no_criteria + p) + length_selected_ndMI;
        
    end
    
    index = cumprod(indices, 2); index = logical(index(:, end));
    
    length_selected_dMI = sum(index);
    
    delta_MI(dMI_marker(no_figures) + (1:length_selected_dMI), :, no_figures) = subj_MI(index, :);
        
    median_subj_dMI(:, no_figures, s) = nanmedian(subj_MI(index, :))';
    
    dMI_marker(no_figures) = dMI_marker(no_figures) + length_selected_dMI;
    
    non_index = cumprod(non_indices, 2); non_index = logical(non_index(:, 3));
    
    length_selected_ndMI = sum(non_index);
    
    non_delta_MI(ndMI_marker(no_figures) + (1:length_selected_ndMI), :, no_figures) = subj_MI(non_index, :);
        
    median_subj_ndMI(:, no_figures, s) = nanmedian(subj_MI(non_index, :))';
    
    ndMI_marker(no_figures) = ndMI_marker(no_figures) + length_selected_ndMI;
    
end

% end_dMI_marker = max(dMI_marker)
% 
% end_ndMI_marker = max(ndMI_marker)
% 
% delta_MI((end_dMI_marker + 1):end, :, :) = [];
% 
% non_delta_MI((end_ndMI_marker + 1):end, :, :) = [];

[median_dMI, median_ndMI] = deal(nan(size(MI, 2), no_figures));

for f = 1:no_figures

    delta_MI(sum(delta_MI(:, :, f), 2) == 0, :, f) = nan;
    
    median_dMI(:, f) = nanmedian(delta_MI(:, :, f))';

    non_delta_MI(sum(non_delta_MI(:, :, f), 2) == 0, :, f) = nan;
    
    median_ndMI(:, f) = nanmedian(non_delta_MI(:, :, f))';
    
end

save([drug, '_delta_MI_q', num2str(quantile_used), '_shm', sprintf('%.03f_%.03f', shm_lims), state_label, '_tails.mat'], '-v7.3',...
    'drug', 'shm_lims', 'state', 'quantile_used', 'delta_MI', 'median_subj_dMI', 'median_dMI',...
    'non_delta_MI', 'median_subj_ndMI', 'median_ndMI')