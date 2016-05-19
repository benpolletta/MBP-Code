function NVP_saline_plot_delta_MI

load('AP_freqs')

figure

%% NVP plot.

load('NVP_delta_MI_q0.1_shm1.025_1.250_W_NR_tails.mat')

cmin = min(min(median_dMI(:, 5)), min(median_ndMI(:, 5)));

cmax = max(max(median_dMI(:, 5)), max(median_ndMI(:, 5)));

subplot(2, 2, 1)

imagesc(phase_freqs, amp_freqs, reshape(median_dMI(:, 5), no_afs, no_pfs))

axis xy

caxis([cmin cmax])
    
title('NVP, Narrowband Delta, W & nREM', 'FontSize', 16)

subplot(2, 2, 2)

imagesc(phase_freqs, amp_freqs, reshape(median_ndMI(:, 5), no_afs, no_pfs))

axis xy

caxis([cmin cmax])
    
title('NVP, Broadband Delta, W & nREM', 'FontSize', 16)

%% Saline plot.

phase_lims = [0 10]; amp_lims = [120 200];
        
phase_indices = find(phase_freqs >= phase_lims(1) & phase_freqs <= phase_lims(2));

amp_indices = find(amp_freqs >= amp_lims(1) & amp_freqs <= amp_lims(2));

rectangle_indices = kron(phase_indices - 1, no_afs*ones(size(amp_indices))) + kron(ones(size(phase_indices)), amp_indices);

load('saline_delta_MI_q0.1_shm1.025_1.250_NR_tails.mat')

cmin = min(min(median_dMI(rectangle_indices, 3)), min(median_ndMI(rectangle_indices, 3)));

cmax = max(max(median_dMI(rectangle_indices, 3)), max(median_ndMI(rectangle_indices, 3)));

subplot(2, 2, 3)

imagesc(phase_freqs, amp_freqs, reshape(median_dMI(:, 3), no_afs, no_pfs))

axis xy

caxis([cmin cmax])
    
title('Saline, Narrowband Delta, QW & nREM', 'FontSize', 16)

subplot(2, 2, 4)

imagesc(phase_freqs, amp_freqs, reshape(median_ndMI(:, 3), no_afs, no_pfs))

axis xy

caxis([cmin cmax])
    
title('Saline, Broadband Delta, QW & nREM', 'FontSize', 16)

save_as_pdf(gcf, 'NVP_saline_delta_MI')


