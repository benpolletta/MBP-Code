function All_summed_MI_plots_Bernat(channel_label)

measure = 'p0.99_IEzs'; stat = 'Median';

state_labels={'W','NR','R'};
% no_states=length(state_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
% no_drugs=length(drug_labels);

name=['ALL_',channel_label];

drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
hrs = text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhrs = text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
sixmins = text_read([name,'/',name,'_',measure,'_6min_periods.txt'],'%s');
states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
load([name,'/',name,'_',measure,'_summed.mat'])
load([name,'/',name,'_',measure,'_MI_pct_by_state.mat'], 'summed_MI_pct_by_state', 'summed_MI_4hr_pct_by_state')

no_bands=length(band_labels);

c_order = [.5 .5 .5; 1 .75 0; 1 0 1; 0 1 1];%[1 .6 0; .6 .4 .8; .59 .29 0; .21 .37 .23];

% NEEDS TO BE FIXED.
%% Barplots by 4 hr period.

% p=1;
% for i=1:1
%     fourhr_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
%     short_fourhr_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
%     p=p+1;
% end
% for i=1:4
%     fourhr_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
%     short_fourhr_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
%     p=p+1;
% end
% 
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour'],[name,'/',name,'_summed_MI_hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_MI)
% 
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name,'_summed_MI_4hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_MI_4hr)

%% Lineplots by hr period.

p=1;
for i=4:-1:1
    hr_labels{p}=['Hour ',num2str(i),' Preinjection'];
    short_hr_labels{p}=['pre',num2str(i)];
    p=p+1;
end
for i=1:20
    hr_labels{p}=['Hour ',num2str(i),' Postinjection'];
    short_hr_labels{p}=['post',num2str(i)];
    p=p+1;
end

% "Raw" summed MI.

% State-dependent.

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by Hour'],[name,'/',name,'_summed_hrMI_hr_by_state'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, short_hr_labels},drugs,states,hrs,summed_MI,stat)

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs'],[name,'/',name,'_summed_4hrMI_hr_by_state'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, short_hr_labels},drugs,states,hrs,summed_MI_4hr,stat)

% State-independent.

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by Hour'],[name,'/',name,'_summed_hrMI_hr'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{short_hr_labels, short_hr_labels},drugs,hrs,summed_MI,stat,c_order)

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs'],[name,'/',name,'_summed_4hrMI_hr'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{short_hr_labels, short_hr_labels},drugs,hrs,summed_MI_4hr,stat,c_order)

% Summed MI as a percentage of baseline.

% State-dependent.

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by Hour, Pct. Change from Baseline'],[name,'/',name,'_summed_hrMI_pct_hr_by_state'],...
    {band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, short_hr_labels},...
    drugs,states,hrs,summed_MI_pct_by_state,stat)

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs, Pct. Change from Baseline'],...
    [name,'/',name,'_summed_4hrMI_pct_hr_by_state'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},...
    {short_hr_labels, short_hr_labels},drugs,states,hrs,summed_MI_4hr_pct_by_state,stat)

% State-independent.

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by Hour, Pct. Change from Baseline'],[name,'/',name,'_summed_hrMI_pct_hr'],...
    {band_labels, band_labels},{drug_labels, drug_labels},{short_hr_labels, short_hr_labels},drugs,hrs,summed_MI_pct,stat,c_order)

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs, Pct. Change from Baseline'],[name,'/',name,'_summed_4hrMI_pct_hr'],...
    {band_labels, band_labels},{drug_labels, drug_labels},{short_hr_labels, short_hr_labels},drugs,hrs,summed_MI_4hr_pct,stat,c_order)

%% Lineplots by 6 min period.

no_pre=2; no_post=8;

[pd_labels, pd_corder]=make_period_labels(no_pre,no_post,'6mins');

% "Raw" summed MI.

% State-dependent.

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by Hour'],[name,'/',name,'_summed_hrMI_6min_by_state'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, pd_labels},drugs,states,sixmins,summed_MI,stat)

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs'],[name,'/',name,'_summed_4hrMI_6min_by_state'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, pd_labels},drugs,states,sixmins,summed_MI_4hr,stat)

% State-independent.

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by Hour'],[name,'/',name,'_summed_hrMI_6min'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI,stat,c_order)

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs'],[name,'/',name,'_summed_4hrMI_6min'],{band_labels, band_labels},...
    {drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI_4hr,stat,c_order)

% Summed MI as a percentage of baseline.

% State-dependent.

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by Hour, Pct. Change from Baseline'],[name,'/',name,'_summed_hrMI_pct_6min_by_state'],...
    {band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, pd_labels},...
    drugs,states,sixmins,summed_MI_pct_by_state,stat)

lineplot_collected_BP_by_3_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs, Pct. Change from Baseline'],[name,'/',name,'_summed_4hrMI_pct_6min_by_state'],...
    {band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, pd_labels},...
    drugs,states,sixmins,summed_MI_4hr_pct_by_state,stat)

% State-independent.

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by Hour, Pct. Change from Baseline'],[name,'/',name,'_summed_hrMI_pct_6min'],...
    {band_labels, band_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI_pct,stat,c_order)

lineplot_collected_BP_by_categories([channel_label, ' MI, z-Scored by State Every 4 Hrs, Pct. Change from Baseline'],[name,'/',name,'_summed_4hrMI_pct_6min'],...
    {band_labels, band_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI_4hr_pct,stat,c_order)

end

