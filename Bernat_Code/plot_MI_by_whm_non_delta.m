function plot_MI_by_whm_non_delta(drug, quantile_used, shm_lim, states, matched_flag)

load('subjects.mat'), load('AP_freqs.mat')

state_label = ''; long_state_label = '';

if ~isempty(states)
    
    no_states = length(states);
    
    for s = 1:no_states
        
        state_label = [state_label, '_', states{s}];
        
        long_state_label = [long_state_label, ', ', states{s}];
        
    end
    
end

if isscalar(shm_lim)
    
    shm_label = ['_shm', num2str(shm_lim)];
    
else
   
    shm_label = sprintf('_shm%.03f_%.03f', shm_lim);
    
end


load([drug, '_delta_MI_q', num2str(quantile_used), '_shm', sprintf('%.03f_%.03f', shm_lim), state_label, matched_flag, '.mat'])

criteria = {'whm', 'shm', 'shm/whm', 'entropy'};

pairs = nchoosek(1:length(criteria), 2);

for c = 1:length(criteria)
    
    delta_labels{c} = ['High ', criteria{c}];
    
end

for p = 1:length(pairs)
    
    delta_labels{length(criteria) + p} = ['High ', criteria{pairs(p, 1)}, ' & ', criteria{pairs(p, 2)}];
    
end

delta_labels{end + 1} = 'High shm & whm & shm/whm & entropy';

no_deltas = length(delta_labels);

[no_rows, no_cols] = subplot_size(no_deltas);

for s = 1:subj_num
    
    subject = subjects{s};
    
    figure
    
    for d = 1:no_deltas
        
        subplot(no_rows, no_cols, d)
        
        imagesc(phase_freqs, amp_freqs, reshape(median_subj_ndMI(:, d, s), no_afs, no_pfs))
        
        axis xy
        
        title(delta_labels{d})
        
    end
    
    mtit([subject, ' MI Outside of Narrowband Delta', long_state_label])
    
    save_as_pdf(gcf, [subject, '_', drug, '_non_delta_MI_q', num2str(quantile_used), shm_label, state_label, matched_flag])
    
end

figure

for d = 1:no_deltas
    
    subplot(no_rows, no_cols, d)
    
    imagesc(phase_freqs, amp_freqs, reshape(median_ndMI(:, d), no_afs, no_pfs))
    
    axis xy
    
    colorbar
    
    title(delta_labels{d})
    
end

mtit(['MI Outside of Narrowband Delta', long_state_label])

save_as_pdf(gcf, [drug, '_non_delta_MI_q', num2str(quantile_used), shm_label, state_label, matched_flag])