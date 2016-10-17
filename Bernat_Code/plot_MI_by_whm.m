function plot_MI_by_whm(drug, quantile_used, shm_lim, states)

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
    
    shm_flag = num2str(shm_lim, '%.03f');
    
elseif length(shm_lim) == 2
    
    shm_flag = sprintf('%.03f_%.03f', shm_lim);
    
end

load([drug, '_delta_MI_q', num2str(quantile_used), '_shm', shm_flag, state_label, '_tails.mat'])

criteria = {'whm', 'shm', 'shm/whm', 'entropy'};

pairs = nchoosek(1:length(criteria), 2);

for c = 1:length(criteria)
    
    delta_labels{c} = ['Low ', criteria{c}];
    
end

for p = 1:length(pairs)
    
    delta_labels{length(criteria) + p} = ['Low ', criteria{pairs(p, 1)}, ' & ', criteria{pairs(p, 2)}];
    
end

delta_labels{end + 1} = 'Low shm & whm & shm/whm & entropy';

no_deltas = length(delta_labels);

[no_rows, no_cols] = subplot_size(no_deltas);

for s = 1:subj_num
    
    subject = subjects{s};
    
    figure
    
    for d = 1:length(delta_labels)
        
        subplot(no_rows, no_cols, d)
        
        imagesc(phase_freqs, amp_freqs, reshape(median_subj_dMI(:, d, s), no_afs, no_pfs))
        
        axis xy
        
        title(delta_labels{d})
        
    end
    
    mtit([subject, ' MI During Narrowband Delta', long_state_label])
    
    save_as_pdf(gcf, [subject, '_', drug, '_delta_MI_q', num2str(quantile_used), '_shm', shm_flag, state_label])
    
end

figure

for d = 1:no_deltas
    
    subplot(no_rows, no_cols, d)
    
    imagesc(phase_freqs, amp_freqs, reshape(median_dMI(:, d), no_afs, no_pfs))
    
    axis xy
    
    colorbar
    
    title(delta_labels{d})
    
end

mtit(['MI During Narrowband Delta', long_state_label])

save_as_pdf(gcf, [drug, '_delta_MI_q', num2str(quantile_used), '_shm', shm_flag, state_label])