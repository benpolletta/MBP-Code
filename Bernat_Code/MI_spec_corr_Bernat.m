function MI_spec_corr_Bernat(drug, spec_norm)

close('all')

%% Loading data.

load('subjects'), load('drugs'), load('channels')

load('AP_freqs'), load('spec_freqs')

[rows, cols] = subplot_size(no_pfs);

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
    
    sMI_drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
    subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
    sMI_hrs = text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
    states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
    % summed_struct = load([name,'/',name,'_',measure,'_summed.mat']);
    % band_labels = summed_struct.band_labels;
    % no_bands = length(band_labels);
    % summed_MI = summed_struct.summed_MI;
    % clear summed_struct
    MI = load([name, '/', name, '_', measure, '_hr_MI.txt']);
    
    load('BP_bands')
    
    name = ['ALL_', channel_names{pairs(p, 2)}];
    
    spec_drugs = text_read([name,'/',name,'_drugs.txt'],'%s');
    subjects = text_read([name,'/',name,'_subjects.txt'],'%s');
    spec_hrs = text_read([name,'/',name,'_hrs.txt'],'%s');
    states = text_read([name,'/',name,'_states.txt'],'%s');
    spec = load([name, '/', name, '_spec', spec_norm, '.txt']);
    
    %% Computing for a given drug.
    
    drug_MI_selected_hrs = nan(220*no_subjects*no_periods, size(MI, 2));
    
    drug_spec_selected_hrs = nan(220*no_subjects*no_periods, size(spec, 2));
    
    for h=1:no_periods
        
        drug_MI_selected_hrs(((h - 1)*220*no_subjects + 1):(h*220*no_subjects), :) = ...
            MI(strcmp(sMI_hrs, hr_periods{h}) & strcmp(sMI_drugs, drug), :);
        
        drug_spec_selected_hrs(((h - 1)*220*no_subjects + 1):(h*220*no_subjects), :) = ...
            spec(strcmp(spec_hrs, hr_periods{h}) & strcmp(spec_drugs, drug), :);
        
    end
    
    All_corrs = nancorr(drug_spec_selected_hrs, drug_MI_selected_hrs);
    
    figure
    
    for pf = 1:no_pfs
        
        subplot(rows, cols, pf)
        
        xlabels = vec_labels((pf - 1)*no_afs + (1:no_afs));
        
        imagesc(spec_freqs, 1:no_afs, All_corrs(:, (pf - 1)*no_afs + (1:no_afs)))
        
        set(gca, 'YTick', 1:floor(no_afs/4):no_afs, 'YTickLabel', xlabels(1:floor(no_afs/4):no_afs))
        
        axis xy
        
        % colorbar
        
        title(sprintf('Phase Freq. = %.02f Hz', phase_freqs(pf)))
        
    end
    
    mtit([drug, ', ', channel_names{pairs(p, 1)}, ' MI by ', channel_names{pairs(p, 2)}, ' spec ', spec_norm(2:end)], 'FontSize', 16)
    
    save_as_pdf(gcf, [drug, '_', channel_names{pairs(p, 1)}, 'MI_', channel_names{pairs(p, 2)}, 'spec', spec_norm])
    
end

end