function MI_BP_6min_corr_Bernat(drug, BP_norm, hr_limits, state)

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

for p = 1:no_pairs
    
    name = ['ALL_', channel_names{pairs(p, 1)}];
    
    measure = 'p0.99_IEzs';
    
    MI_drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
    subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
    MI_hrs = text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
    MI_states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
    MI = load([name, '/', name, '_', measure, '_hr_MI.txt']);
    
    load('BP_bands')
    
    name = ['ALL_', channel_names{pairs(p, 2)}];
    
    if isempty(state)
    
        name = ['ALL_', channel_names{pairs(p, 1)}];
        
        MI_struct = load([name, '/', name, '_', measure, '_MI/', name, '_', measure, '_hrMI_6min_', drug, '_cplot_data.mat']);
        MI_data = MI_struct.MI_stats;
        MI_dims = size(MI_data);
        MI_drug_data = reshape(MI_data, [MI_dims(1)*MI_dims(2), MI_dims([4 5])]);
        MI_pds = MI_struct.cat2_labels;
        
        name = ['ALL_', channel_names{pairs(p, 2)}];
        
        BP_struct = load([name, '/', name, '_BP', BP_norm, '_6min.mat']);
        BP_data = BP_struct.BP_stats;
        BP_drugs = BP_struct.cat1_labels;
        BP_drug_data = BP_data(:, :, :, strcmp(BP_drugs, drug));
        BP_pds = BP_struct.cat2_labels;
        
    else
        
        name = ['ALL_', channel_names{pairs(p, 1)}];
        
        MI_struct = load([name, '/', name, '_', measure, '_MI/', name, '_', measure, '_hrMI_6min_by_state_cplot_data.mat']);
        MI_data = MI_struct.MI_stats;
        MI_dims = size(MI_data);
        MI_drugs = MI_struct.cat3_labels;
        MI_drug_data = reshape(MI_data(:, :, strcmp(MI_struct.cat1_labels, state),...
            :, strcmp(MI_drugs, drug), :), [MI_dims(1)*MI_dims(2), MI_dims([4 6])]);
        MI_pds = MI_struct.cat2_labels;
        
        name = ['ALL_', channel_names{pairs(p, 2)}];
        
        BP_struct = load([name, '/', name, '_BP', BP_norm, '_6min_by_state.mat']);
        BP_data = BP_struct.BP_stats;
        BP_dims = size(BP_data);
        BP_drugs = BP_struct.cat3_labels;
        BP_drug_data = reshape(BP_data(:, strcmp(BP_struct.cat1_labels, state),...
            :, :, strcmp(BP_drugs, drug)), BP_dims([1 3 4]));
        BP_pds = BP_struct.cat2_labels;
        
    end
    
    %% Computing for a given drug.
    
    MI_pds = str2double(cellstr(MI_pds)); BP_pds = str2double(cellstr(BP_pds));
    
    MI_pd_index = MI_pds >= min(sixmin_periods) & MI_pds <= max(sixmin_periods);
    
    BP_pd_index = BP_pds >= min(sixmin_periods) & BP_pds <= max(sixmin_periods);
    
    drug_MI_selected_hrs = MI_drug_data(:, MI_pd_index, 1)';
    
    drug_BP_selected_hrs = BP_drug_data(:, BP_pd_index, 1)';
    
    All_corrs = nancorr(drug_MI_selected_hrs, drug_BP_selected_hrs);
    
    figure
    
    for band = 1:size(BP_drug_data, 1)
        
        subplot(rows, cols, band)
        
        imagesc(phase_freqs, amp_freqs, reshape(All_corrs(:, band), no_afs, no_pfs))
        
        axis xy
        
        colorbar
        
        title(band_labels_long{band})
        
    end
    
    mtit(sprintf('%s, %s MI by %s BP%s, %d to %d Hours, %s', drug, channel_names{pairs(p, :)}, BP_norm(2:end), hr_limits, state), 'FontSize', 16)
    
    save_as_pdf(gcf, sprintf('%s_%sMI_%sBP%s_%dto%dhrs_%s_by_6min', drug, channel_names{pairs(p, :)}, BP_norm, hr_limits, state))
    
end

end