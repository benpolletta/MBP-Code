function NVP_BP_theta_delta_stats

close('all')

%% Loading data.

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')
    
load('BP_bands')

name = 'ALL_Frontal';

Frontal_BP_drugs = text_read([name, '/', name, '_drugs.txt'], '%s');
% Frontal_BP_subjects = text_read([name, '/', name, '_subjects.txt'], '%s');
Frontal_BP_6mins = text_read([name, '/', name, '_6mins.txt'], '%s');
% Frontal_BP_states = text_read([name, '/', name, '_states.txt'], '%s');
Frontal_BP = load([name, '/', name, '_BP.txt']);

name = 'ALL_CA1';

CA1_BP_drugs = text_read([name,'/',name,'_drugs.txt'],'%s');
% CA1_BP_subjects = text_read([name,'/',name,'_subjects.txt'],'%s');
CA1_BP_6mins = text_read([name,'/',name,'_6mins.txt'],'%s');
% CA1_BP_states = text_read([name,'/',name,'_states.txt'],'%s');
CA1_BP = load([name, '/', name, '_BP.txt']);

BP = Frontal_BP; BP(:, :, 2) = CA1_BP;

%% Setting up info. about periods.

pd_labels = make_period_labels(0, 4, '6mins');

no_pds = length(pd_labels);

%% Comparing frontal & CA1 delta & theta.

band_orders = [1 2; 2 1];

p_vals = nan(no_pds, 2, 2);

for order = 1:2
    
    for pd = 1:no_pds
        
        BP1 = BP(strcmp(Frontal_BP_6mins, pd_labels{pd}) & strcmp(Frontal_BP_drugs, 'NVP'), band_orders(order, 1), 1);
        
        BP2 = BP(strcmp(CA1_BP_6mins, pd_labels{pd}) & strcmp(CA1_BP_drugs, 'NVP'), band_orders(order, 2), 2);
        
        ranksum_p_vals(pd, 1, order) = ranksum(BP1, BP2, 'tail', 'right');
        
        ranksum_p_vals(pd, 2, order) = ranksum(BP1, BP2, 'tail', 'left');
        
        ttest_p_vals(pd, 1, order) = ttest(BP1, BP2, 'tail', 'right');
        
        ttest_p_vals(pd, 2, order) = ttest(BP1, BP2, 'tail', 'left');
        
    end

end

save('NVP_BP_theta_delta_stats.mat', 'p_vals')

end