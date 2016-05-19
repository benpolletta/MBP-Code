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

load([drug, '_delta_MI_q', num2str(quantile_used), '_shm', num2str(shm_lim), state_label, '.mat'])

delta_labels = {'Low whm', 'Low shm', 'Low shm/whm', 'Low whm & shm', 'Low whm & shm/whm', 'Low shm & shm/whm', 'Low whm & shm & shm/whm'};

for s = 1:subj_num
    
    subject = subjects{s};
    
    figure
    
    for i = 1:7
        
        subplot(3, 3, i)
        
        imagesc(phase_freqs, amp_freqs, reshape(median_subj_dMI(:, i, s), no_afs, no_pfs))
        
        axis xy
        
        title(delta_labels{i})
        
    end
    
    mtit([subject, ' MI During Narrowband Delta', long_state_label])
    
    save_as_pdf(gcf, [subject, '_', drug, '_delta_MI_q', num2str(quantile_used), '_shm', num2str(shm_lim), state_label])
    
end

figure

for i = 1:7
    
    subplot(3, 3, i)
    
    imagesc(phase_freqs, amp_freqs, reshape(median_dMI(:, i), no_afs, no_pfs))
    
    axis xy
    
    colorbar
    
    title(delta_labels{i})
    
end

mtit(['MI During Narrowband Delta', long_state_label])

save_as_pdf(gcf, [drug, '_delta_MI_q', num2str(quantile_used), '_shm', num2str(shm_lim), state_label])