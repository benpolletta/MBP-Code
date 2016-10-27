function NVP_deltaHFO_thetaHFO_plot

load('AP_freqs')

figure

%% Plotting Occipital MI for hour 3.
            
load(['ALL_Occipital/ALL_Occipital_p0.99_IEzs_MI/',...
    'ALL_Occipital_p0.99_IEzs_hrMI_hr_NVP_cplot_data.mat'])

p4_indicator = strcmp(cat2_labels, 'post4');

subplot(2, 3, 1)

imagesc(phase_freqs, amp_freqs, MI_stats(:, :, :, p4_indicator, 1))

axis xy

colorbar

title({'All Occipital PAC'; 'Hr. 4 Post-Injection'; 'Median MI'}, 'FontSize', 16)

ylabel('Amp. Freq. (Hz)', 'FontSize', 14)

xlabel('Phase Freq. (Hz)', 'FontSize', 14)

%% Plotting top quartiles for delta-HFO and theta-HFO PAC.

load('dHFO_tHFO_quantiles_hihr_q0.25.mat')

HFO_labels = {'\delta-HFO', '\theta-HFO'};

for lf = 1:2
    
    subplot(2, 3, 1 + lf)
    
    imagesc(phase_freqs, amp_freqs, reshape(median_qPAC(:, lf, 3, 2), no_afs, no_pfs))
    
    axis xy
    
    colorbar
    
    title({['Top Quartile for ', HFO_labels{lf}, ' PAC']; 'Hr. 4 Post-Injection'; 'Median MI'}, 'FontSize', 16)
    
    xlabel('Phase Freq. (Hz)', 'FontSize', 14)
    
end

%% Plotting delta-HFO against theta-HFO.

ch_dir = 'ALL_Occipital'; measure = 'p0.99_IEzs'; q = .25;

sMI = load([ch_dir, '/', ch_dir, '_', measure, '_summed.mat']);
sMI = sMI.summed_MI;
drugs = text_read([ch_dir,'/',ch_dir, '_', measure,'_drugs.txt'],'%s');
subjects = text_read([ch_dir,'/',ch_dir, '_', measure,'_subjects.txt'],'%s');
hrs = text_read([ch_dir,'/',ch_dir, '_', measure,'_hrs.txt'],'%s');
p4_index = strcmp(hrs, 'post1') | strcmp(hrs, 'post2') |...
    strcmp(hrs, 'post3') | strcmp(hrs, 'post4');
states = text_read([ch_dir,'/',ch_dir, '_', measure,'_states.txt'],'%s');

subject = 'A99'; drug = 'NVP'; ds_factor = 22;

subj_deltaHFO = nanzscore(sMI(strcmp(subjects, subject) & p4_index & strcmp(drugs, drug), end - 1));

subj_deltaHFO = downsample(subj_deltaHFO, ds_factor);

subj_deltaHFO_high = subj_deltaHFO;

subj_deltaHFO_high(subj_deltaHFO < quantile(subj_deltaHFO, 1 - q)) = nan;

subj_thetaHFO = nanzscore(sMI(strcmp(subjects, subject) & p4_index & strcmp(drugs, drug), end));

subj_thetaHFO = downsample(subj_thetaHFO, ds_factor);

subj_thetaHFO_high = subj_thetaHFO;

subj_thetaHFO_high(subj_thetaHFO < quantile(subj_thetaHFO, 1 - q)) = nan;

subplot(2, 2, 3)

hrs = 4*(1:length(subj_deltaHFO))/length(subj_deltaHFO);

plot(hrs', [subj_deltaHFO subj_thetaHFO])

hold on

plot(hrs', [subj_deltaHFO_high subj_thetaHFO_high], 'o') % , 'LineWidth', 2)

legend({'\delta-HFO PAC','\theta-HFO PAC'})

axis tight

plot(hrs', zeros(size(subj_deltaHFO)), '--k')

box off

title({'Occipital \delta-HFO and \theta-HFO PAC Post-Injection'; '(Representative Individual)'}, 'FontSize', 16)

ylabel('Mean MI (a.u.)', 'FontSize', 14)

xlabel('Time (h) Rel. Injection', 'FontSize', 14)

%% Plotting correlation of delta-HFO and theta-HFO PAC.

load(['Occipital_NVP_thetaHFO_deltaHFO_multidrug_ds', num2str(ds_factor, '%.3g'), '.mat'])

subplot(2, 3, 6)

imagesc(c{1}, c{2}, n)

axis xy

xlabel('\delta-HFO PAC (a. u.)', 'FontSize', 14)

ylabel('\theta-HFO PAC (a. u.)', 'FontSize', 14)

hold on

plot(c{1}, p_fit(1)*c{1} + p_fit(2), 'w')

title({'Correlation of Post-Injection \delta-HFO and \theta-HFO PAC'; ['\rho = ', num2str(rho, '%.3g'), ', p = ', num2str(p, '%.3g')]}, 'FontSize', 16)

save_as_pdf(gcf, 'NVP_dHFO_tHFO_figure')
