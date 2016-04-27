function NVP_MI_BP_corr_Bernat

close('all')

%% Loading data.

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')

[rows, cols] = subplot_size(size(band_limits, 1));

pairs = [cumsum(ones(3, 2)); nchoosek(1:3, 2); fliplr(nchoosek(1:3, 2))];

no_pairs = length(pairs);

%% Setting up information about periods (time since injection).

hrs_pre = 0;
hrs_post = 4;
[hr_periods, ~, long_hr_periods] = make_period_labels(hrs_pre, hrs_post, 'hrs');
no_periods = length(hr_periods);

for p = 1:no_pairs
    
    name = ['ALL_', channel_names{pairs(p, 1)}];
    
    measure = 'p0.99_IEzs';
    
    MI_drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
    subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
    MI_hrs = text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
    states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
    MI = load([name, '/', name, '_', measure, '_hr_MI.txt']);
    
    load('BP_bands')
    
    name = ['ALL_', channel_names{pairs(p, 2)}];
    
    BP_drugs = text_read([name,'/',name,'_drugs.txt'],'%s');
    subjects = text_read([name,'/',name,'_subjects.txt'],'%s');
    BP_hrs = text_read([name,'/',name,'_hrs.txt'],'%s');
    states = text_read([name,'/',name,'_states.txt'],'%s');
    BP = load([name, '/', name, '_BP.txt']);
    
    %% Cycling through drugs.
    
    for d = 3 % 1:no_drugs
        
        drug = drugs{d};
        
        drug_MI_selected_hrs = nan(220*no_subjects*no_periods, size(MI, 2));
        
        drug_BP_selected_hrs = nan(220*no_subjects*no_periods, size(BP, 2));
        
        for h=1:no_periods
            
            drug_MI_selected_hrs(((h - 1)*220*no_subjects + 1):(h*220*no_subjects), :) = ...
                MI(strcmp(MI_hrs, hr_periods{h}) & strcmp(MI_drugs, drug), :);
            
            drug_BP_selected_hrs(((h - 1)*220*no_subjects + 1):(h*220*no_subjects), :) = ...
                BP(strcmp(BP_hrs, hr_periods{h}) & strcmp(BP_drugs, drug), :);
            
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
        
        mtit([drug, ', ', channel_names{pairs(p, 1)}, ' MI by ', channel_names{pairs(p, 2)}, ' BP'], 'FontSize', 16)
        
        save_as_pdf(gcf, [drug, '_', channel_names{pairs(p, 1)}, 'MI_', channel_names{pairs(p, 2)}, 'BP'])
        
    end
    
end

end