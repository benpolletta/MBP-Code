function MI_BP_6min_corr_by_subject(drug, BP_norm, hr_limits)

close('all')

%% Defaults.

if isempty(hr_limits), hr_limits = [0 4]; end

%% Loading data.

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')

[rows, cols] = subplot_size(size(band_limits, 1));

pairs = [cumsum(ones(3, 2)); nchoosek(1:3, 2); fliplr(nchoosek(1:3, 2))];

no_pairs = length(pairs);

%% Setting up information about periods (time since injection).

hrs_pre = hr_limits(1);
hrs_post = hr_limits(2);
[sixmin_periods, ~, ~] = make_period_labels(hrs_pre, hrs_post, '6mins');
sixmin_periods = str2double(cellstr(sixmin_periods));
no_periods = length(sixmin_periods);

MI_all_data = nan(no_afs*no_pfs, 0);

BP_all_data = nan(size(band_limits, 1), 0);

[MI_all_pds, BP_all_pds] = deal(nan(0));

All_corrs = nan(no_afs*no_pfs, size(band_limits, 1), no_pairs, no_subjects + 1);

for p = 1:no_pairs
    
    for s = 1:no_subjects
        
        measure = 'p0.99_IEzs';
        
        load('BP_bands')
        
        name = ['ALL_', channel_names{pairs(p, 1)}];
        
        MI_struct = load([name, '/', name, '_', measure, '_MI/', name, '_', measure,...
            '_6min_', subjects{s}, '_', drug, '_cplot_data.mat']);
        MI_data = MI_struct.MI_stats;
        MI_dims = size(MI_data);
        MI_drug_data = reshape(MI_data, [MI_dims(1)*MI_dims(2), MI_dims([4 5])]);
        MI_all_data(:, (end + 1):(end + MI_dims(4))) = MI_drug_data(:, :, 1);
        MI_pds = str2double(cellstr(MI_struct.cat2_labels));
        MI_all_pds((end + 1):(end + length(MI_pds))) = MI_pds;
        
        name = ['ALL_', channel_names{pairs(p, 2)}];
        
        BP_struct = load([name, '/', name, '_', subjects{s}, '_BP', BP_norm, '_6min_BP_stats.mat']);
        BP_data = BP_struct.BP_stats;
        BP_drugs = BP_struct.cat1_labels;
        BP_drug_data = BP_data(:, :, :, strcmp(BP_drugs, drug));
        BP_all_data(:, (end + 1):(end + size(BP_drug_data, 2))) = BP_drug_data(:, :, 1);
        BP_pds = str2double(cellstr(BP_struct.cat2_labels));
        BP_all_pds((end + 1):(end + length(BP_pds))) = BP_pds;
        
        %% Computing for a given drug.
        
        MI_pd_index = MI_pds >= min(sixmin_periods) & MI_pds <= max(sixmin_periods);
        
        BP_pd_index = BP_pds >= min(sixmin_periods) & BP_pds <= max(sixmin_periods);
        
        drug_MI_selected_hrs = MI_drug_data(:, MI_pd_index, 1)';
        
        drug_BP_selected_hrs = BP_drug_data(:, BP_pd_index, 1)';
        
        pair_corrs = nancorr(drug_MI_selected_hrs, drug_BP_selected_hrs);
        
        figure
        
        for band = 1:size(BP_drug_data, 1)
            
            subplot(rows, cols, band)
            
            imagesc(phase_freqs, amp_freqs, reshape(pair_corrs(:, band), no_afs, no_pfs))
            
            axis xy
            
            colorbar
            
            title(band_labels_long{band})
            
        end
        
        All_corrs(:, :, p, s) = pair_corrs;
        
        mtit(sprintf('%s, %s, %s MI by %s BP%s, %d to %d Hours', subjects{s},...
            drug, channel_names{pairs(p, :)}, BP_norm(2:end), hr_limits), 'FontSize', 16)
        
        save_as_pdf(gcf, sprintf('%s_%s_%sMI_%sBP%s_%dto%dhrs_by_6min', subjects{s},...
            drug, channel_names{pairs(p, :)}, BP_norm, hr_limits))
        
    end
    
    MI_pd_index = MI_all_pds >= min(sixmin_periods) & MI_all_pds <= max(sixmin_periods);
    
    BP_pd_index = BP_all_pds >= min(sixmin_periods) & BP_all_pds <= max(sixmin_periods);
    
    drug_MI_selected_hrs = MI_all_data(:, MI_pd_index)';
    
    drug_BP_selected_hrs = BP_all_data(:, BP_pd_index)';
    
    All_corrs(:, :, p, end) = nancorr(drug_MI_selected_hrs, drug_BP_selected_hrs);
    
    figure
    
    for band = 1:size(BP_drug_data, 1)
        
        subplot(rows, cols, band)
        
        imagesc(phase_freqs, amp_freqs, reshape(All_corrs(:, band, p, end), no_afs, no_pfs))
        
        axis xy
        
        colorbar
        
        title(band_labels_long{band})
        
    end
    
    mtit(sprintf('%s, %s MI by %s BP%s, %d to %d Hours',...
        drug, channel_names{pairs(p, :)}, BP_norm(2:end), hr_limits), 'FontSize', 16)
    
    save_as_pdf(gcf, sprintf('%s_%sMI_%sBP%s_%dto%dhrs_by_6min',...
        drug, channel_names{pairs(p, :)}, BP_norm, hr_limits))
    
end
    
save(sprintf('%s_MI_BP%s_%dto%dhrs_by_6min_by_subject', drug, BP_norm, hr_limits),...
    'drug', 'BP_norm', 'hr_limits', 'subjects', 'All_corrs')

end