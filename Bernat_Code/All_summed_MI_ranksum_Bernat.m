function All_summed_MI_ranksum_Bernat(channel_label, measure)

% subjects={'A99','A102','A103','A104','A105','A106'};
% subj_num=length(subjects);

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
%load([name,'/',name,'_',measure,'_summed_pct.mat']) %No longer necessary,
%since now normalization is done before summing (10/16/14).

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
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour'],[name,'/',name,'_summed_MI_hr_by_4hr'],{band_labels, band_labels},{state_labels, state_labels},{drug_labels, drug_labels},{short_fourhr_labels, fourhr_labels},states,drugs,fourhrs,summed_MI)
% 
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name,'_summed_MI_4hr_by_4hr'],{band_labels, band_labels},{state_labels, state_labels},{drug_labels, drug_labels},{short_fourhr_labels, fourhr_labels},states,drugs,fourhrs,summed_MI_4hr)

%% Lineplots by hr period.

hr_labels = cell(24, 1); short_hr_labels = cell(24, 1);

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

stats_collected_BP_by_3_categories([name,'/',name,'_summed_hrMI_hr_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{short_hr_labels, short_hr_labels},states,drugs,hrs,summed_MI)

stats_collected_BP_by_3_categories([name,'/',name,'_summed_4hrMI_hr_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{short_hr_labels, short_hr_labels},states,drugs,hrs,summed_MI_4hr)

% stats_collected_BP_by_categories([name,'/',name,'_summed_hrMI_hr'],{band_labels, band_labels},{drug_labels, drug_labels},...
%    {short_hr_labels, short_hr_labels},drugs,hrs,summed_MI)
% 
% stats_collected_BP_by_categories([name,'/',name,'_summed_4hrMI_hr'],{band_labels, band_labels},{drug_labels, drug_labels},...
%     {short_hr_labels, short_hr_labels},drugs,hrs,summed_MI_4hr)

% Summed MI as a percentage of baseline.

stats_collected_BP_by_3_categories([name,'/',name,'_summed_hrMI_pct_hr_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{short_hr_labels, short_hr_labels},states,drugs,hrs,summed_MI_pct)

stats_collected_BP_by_3_categories([name,'/',name,'_summed_4hrMI_pct_hr_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{short_hr_labels, short_hr_labels},states,drugs,hrs,summed_MI_4hr_pct)

stats_collected_BP_by_categories([name,'/',name,'_summed_hrMI_pct_hr'],{band_labels, band_labels},{drug_labels, drug_labels},...
    {short_hr_labels, short_hr_labels},drugs,hrs,summed_MI_pct)

stats_collected_BP_by_categories([name,'/',name,'_summed_4hrMI_pct_hr'],{band_labels, band_labels},{drug_labels, drug_labels},...
    {short_hr_labels, short_hr_labels},drugs,hrs,summed_MI_4hr_pct)

%% Lineplots by 6 min period.

no_pre=2; no_post=8;

[pd_labels, ~]=make_period_labels(no_pre,no_post,'6mins');

% "Raw" summed MI.

stats_collected_BP_by_3_categories([name,'/',name,'_summed_hrMI_6min_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{pd_labels, pd_labels},states,drugs,sixmins,summed_MI)

stats_collected_BP_by_3_categories([name,'/',name,'_summed_4hrMI_6min_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{pd_labels, pd_labels},states,drugs,sixmins,summed_MI_4hr)

% stats_collected_BP_by_categories([name,'/',name,'_summed_hrMI_6min'],{band_labels, band_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI)
% 
% stats_collected_BP_by_categories([name,'/',name,'_summed_4hrMI_6min'],{band_labels, band_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI_4hr)

% Summed MI as a percentage of baseline.

stats_collected_BP_by_3_categories([name,'/',name,'_summed_hrMI_pct_6min_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{pd_labels, pd_labels},states,drugs,sixmins,summed_MI_pct)

stats_collected_BP_by_3_categories([name,'/',name,'_summed_4hrMI_pct_6min_by_state'],{band_labels, band_labels},{state_labels, state_labels},...
    {drug_labels, drug_labels},{pd_labels, pd_labels},states,drugs,sixmins,summed_MI_4hr_pct)

stats_collected_BP_by_categories([name,'/',name,'_summed_hrMI_pct_6min'],{band_labels, band_labels},{drug_labels, drug_labels},...
    {pd_labels, pd_labels},drugs,sixmins,summed_MI_pct)

stats_collected_BP_by_categories([name,'/',name,'_summed_4hrMI_pct_6min'],{band_labels, band_labels},{drug_labels, drug_labels},...
    {pd_labels, pd_labels},drugs,sixmins,summed_MI_4hr_pct)

end
