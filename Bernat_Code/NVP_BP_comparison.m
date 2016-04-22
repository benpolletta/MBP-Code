function NVP_BP_comparison(drug, BP_norm, hr_limits, state)

close('all')

%% Defaults.

if isempty(hr_limits), hr_limits = [0 4]; end

%% Loading data.

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')

%% Setting up information about periods (time since injection).

hrs_pre = hr_limits(1);
hrs_post = hr_limits(2);
[hr_periods, ~, long_hr_periods] = make_period_labels(hrs_pre, hrs_post, 'hrs');
no_periods = length(hr_periods);
    
load('BP_bands')

name = 'ALL_Frontal';

Frontal_BP_struct = load([name, '/', name, '_BP', BP_norm, '_6min.mat']);
Frontal_BP_data = Frontal_BP_struct.BP_stats;
Frontal_BP_pds = Frontal_BP_struct.cat2_labels;
Frontal_BP_drugs = CA1_BP_struct.cat1_labels;

name = 'ALL_CA1';

CA1_BP_struct = load([name, '/', name, '_BP', BP_norm, '_6min.mat']);
CA1_BP_data = CA1_BP_struct.BP_stats;
CA1_BP_pds = CA1_BP_struct.cat2_labels;
CA1_BP_drugs = CA1_BP_struct.cat1_labels;

%% Comparing frontal delta & CA1 theta.
        
        Frontal_index = strcmp(MI_hrs, 'post1') & strcmp(MI_drugs, drug);

Frontal_delta_hr1 = Frontal_BP_data(


    
    %% Computing for a given drug.
    
    drug_MI_selected_hrs = nan(220*no_subjects*no_periods, size(MI, 2));
    
    drug_BP_selected_hrs = nan(220*no_subjects*no_periods, size(BP, 2));
        
        BP_index = strcmp(BP_hrs, 'post1') & strcmp(CA1_BP_drugs, drug) & BP_state_index;
        
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