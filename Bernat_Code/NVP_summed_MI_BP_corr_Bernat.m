function NVP_summed_MI_BP_corr_Bernat

close('all')

%% Loading data.

load('AP_freqs'), load('subjects'), load('drugs'), load('BP_bands')

[rows, cols] = subplot_size(size(band_limits, 1));

name = 'ALL_Frontal';

measure = 'p0.99_IEzs';

sMI_drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
sMI_hrs = text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
summed_struct = load([name,'/',name,'_',measure,'_summed.mat']);
band_labels = summed_struct.band_labels;
no_bands = length(band_labels);
summed_MI = summed_struct.summed_MI;
clear summed_struct

load('BP_bands')

name = 'ALL_CA1';

BP_drugs = text_read([name,'/',name,'_drugs.txt'],'%s');
subjects = text_read([name,'/',name,'_subjects.txt'],'%s');
BP_hrs = text_read([name,'/',name,'_hrs.txt'],'%s');
states = text_read([name,'/',name,'_states.txt'],'%s');
BP = load([name, '/', name, '_BP.txt']);

%% Setting up information about periods (time since injection).

hrs_pre = 2;
hrs_post = 6;
[hr_periods, ~, long_hr_periods] = make_period_labels(hrs_pre, hrs_post, 'hrs');
no_periods = length(hr_periods);

%% Cycling through drugs.

for d = 3 % 1:no_drugs
    
    drug = drugs{d};
    
    drug_summed_MI_selected_hrs = nan(220*no_subjects*no_periods, size(summed_MI, 2));
    
    drug_BP_selected_hrs = nan(220*no_subjects*no_periods, size(BP, 2));
    
    for h=1:no_periods
        
        drug_summed_MI_selected_hrs(((h - 1)*220*no_subjects + 1):(h*220*no_subjects), :) = ...
            summed_MI(strcmp(sMI_hrs, hr_periods{h}) & strcmp(sMI_drugs, drug), :);
        
        drug_BP_selected_hrs(((h - 1)*220*no_subjects + 1):(h*220*no_subjects), :) = ...
            BP(strcmp(BP_hrs, hr_periods{h}) & strcmp(BP_drugs, drug), :);
        
    end
    
    All_corrs = nancorr(drug_summed_MI_selected_hrs, drug_BP_selected_hrs);
        
    imagesc(All_corrs)
    
end

end