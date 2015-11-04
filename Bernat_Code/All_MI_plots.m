function All_MI_plots(channel_label)

measure = 'p0.99_IEzs';

amps=20:5:200; phases=1:.25:12;
matrix_rows=length(amps); matrix_columns=length(phases);

name=['ALL_',channel_label];

subjects=text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
drugs=text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
hr_periods=text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhr_periods=text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
states=text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
    
long_state_labels={'Wake','NREM','REM'};
state_labels={'W','NR','R'};
no_states=length(state_labels);

subj_labels={'A99','A102','A103','A104','A105','A106'};
no_subjects=length(subj_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
no_drugs=length(drug_labels);

fig_dir=[name,'/',name,'_',measure,'_MI'];
mkdir (fig_dir)

norms = {'', '_pct'}; no_norms = length(norms);

%% Figures by hour.

MI = load([name,'/',name,'_',measure,'_hr_MI.txt'],'%s');
MI_pct = load([name,'/',name,'_',measure,'_hr_MI_pct.txt'],'%s');
MI_pct_by_state = load([name,'/',name,'_p0.99_IEzs_MI_pct_by_state.mat'], 'MI_pct');
MI_pct_by_state = MI_pct_by_state.MI_pct;
MI_4hr_pct_by_state = load([name,'/',name,'_p0.99_IEzs_MI_pct_by_state.mat'], 'fourhrMI_pct');
MI_4hr_pct_by_state = MI_4hr_pct_by_state.fourhrMI_pct;

period_labels = cell(16,1);
short_period_labels = cell(16,1);
p=1;
for i=4:-1:1
    period_labels{p}=['Hour ',num2str(i),' Preinjection'];
    short_period_labels{p}=['pre',num2str(i)];
    p=p+1;
end
for i=1:12
    period_labels{p}=['Hour ',num2str(i),' Postinjection'];
    short_period_labels{p}=['post',num2str(i)];
    p=p+1;
end
no_periods = length(period_labels);

%% For each drug.

for d=1:no_drugs
    
    % State-independent.
    
    cplot_collected_MI_by_categories([fig_dir,'/',name,'_',measure,'_hrMI_hr_',drug_labels{d}],4,4,phases,amps,...
        {drug_labels(d), drug_labels(d)},{short_period_labels, period_labels},drugs,hr_periods,MI)
    
    cplot_collected_MI_by_categories([fig_dir,'/',name,'_',measure,'_hrMI_hr_pct_',drug_labels{d}],4,4,phases,amps,...
        {drug_labels(d), drug_labels(d)},{short_period_labels, period_labels},drugs,hr_periods,MI_pct)
    
    % State-dependent.
    
    cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_hrMI_hr_by_state_',drug_labels{d}],...
        no_states,no_periods,phases,amps,{drug_labels(d),drug_labels(d)},{state_labels, long_state_labels},...
        {short_period_labels, period_labels},drugs,states,hr_periods,MI)
    
    cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_hrMI_hr_pct_by_state_',drug_labels{d}],...
        no_states,no_periods,phases,amps,{drug_labels(d),drug_labels(d)},{state_labels, long_state_labels},...
        {short_period_labels, period_labels},drugs,states,hr_periods,MI_pct_by_state)
    
    cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_4hrMI_hr_pct_by_state_',drug_labels{d}],...
        no_states,no_periods,phases,amps,{drug_labels(d),drug_labels(d)},{state_labels, long_state_labels},...
        {short_period_labels, period_labels},drugs,states,hr_periods,MI_4hr_pct_by_state)
    
    
end
    
%% By state & hour.

cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_hrMI_hr_by_state'],no_states,no_periods,phases,amps,...
    {drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},drugs,states,hr_periods,MI)

cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_hrMI_hr_pct_by_state'],no_states,no_periods,phases,amps,...
    {drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},drugs,states,hr_periods,MI_pct_by_state)

cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_4hrMI_hr_pct_by_state'],no_states,no_periods,phases,amps,...
    {drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},drugs,states,hr_periods,MI_4hr_pct_state)

%% Figures by state and 4 hour period.

MI=load([name,'/',name,'_',measure,'_4hr_MI.txt'],'%s');

clear period_labels; clear short_period_labels; p=1;
for i=1:1
    period_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
    short_period_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
    p=p+1;
end
for i=1:4
    period_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
    short_period_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
    p=p+1;
end
no_periods=length(period_labels);

cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_hrMI_4hr_by_state'],no_states,no_periods,phases,amps,...
    {drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},drugs,states,fourhr_periods,MI)

cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_hrMI_4hr_pct_by_state'],no_states,no_periods,phases,amps,...
    {drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},drugs,states,fourhr_periods,MI_pct_by_state)

cplot_collected_MI_by_3_categories([fig_dir,'/',name,'_',measure,'_4hrMI_4hr_pct_by_state'],no_states,no_periods,phases,amps,...
    {drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},drugs,states,fourhr_periods,MI_4hr_pct_by_state)

end