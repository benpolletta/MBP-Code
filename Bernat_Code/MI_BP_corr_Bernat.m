function MI_BP_corr_Bernat(drug, BP_norm, hr_limits, state)

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
[hr_periods, ~, long_hr_periods] = make_period_labels(hrs_pre, hrs_post, 'hrs');
no_periods = length(hr_periods);

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
    
    BP_struct = load([name, '/', name, '_BP', BP_norm, '_6min.mat']);
    BP_data = BP_struct.BP_stats;
    BP_pds = BP_struct.cat2_labels;
    BP_drugs = BP_structs.cat1_labels;
    
    %% Selecting states.
    
    if ~isempty(state)
        
        MI_state_index = strcmp(MI_states, state);
        
        BP_state_index = strcmp(BP_states, state);
        
    else
        
        MI_state_index = ones(size(MI_states));
        
        BP_state_index = ones(size(BP_states));
        
    end
    
    %% Computing for a given drug.
    
    drug_MI_selected_hrs = nan(220*no_subjects*no_periods, size(MI, 2));
    
    drug_BP_selected_hrs = nan(220*no_subjects*no_periods, size(BP, 2));
    
    marker = 0;
    
    for h = 1:no_periods
        
        MI_index = strcmp(MI_hrs, hr_periods{h}) & strcmp(MI_drugs, drug) & MI_state_index;
        
        BP_index = strcmp(BP_hrs, hr_periods{h}) & strcmp(BP_drugs, drug) & BP_state_index;
        
        if sum(MI_index) == sum(BP_index)
            
            no_epochs = sum(MI_index);
            
            drug_MI_selected_hrs((marker + 1):(marker + no_epochs), :) = MI(MI_index, :);
            
            drug_BP_selected_hrs((marker + 1):(marker + no_epochs), :) = BP(BP_index, :);
            
            marker = marker + no_epochs;
            
        else
            
            display(sprintf('No. epochs not equal for hour %d.', h))
            
        end
        
    end
    
    All_corrs = nancorr(drug_MI_selected_hrs, drug_BP_selected_hrs);
    
    figure
    
    for band = 1:size(BP, 2)
        
        subplot(rows, cols, band)
        
        imagesc(phase_freqs, amp_freqs, reshape(All_corrs(:, band), no_afs, no_pfs))
        
        axis xy
        
        colorbar
        
        title(band_labels_long{band})
        
    end
    
    mtit(sprintf('%s, %s MI by %s BP%s, %d to %d Hours, %s', drug, channel_names{pairs(p, :)}, BP_norm(2:end), hr_limits, state), 'FontSize', 16)
    
    save_as_pdf(gcf, sprintf('%s_%sMI_%sBP%s_%dto%dhrs_%s', drug, channel_names{pairs(p, :)}, BP_norm, hr_limits, state))
    
end

end