function All_BP_plots_Bernat(channel_label)

% subjects={'A99','A102','A103','A104','A105','A106'};
% subj_num=length(subjects);

state_labels={'W','NR','R'};
% no_states=length(state_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
% no_drugs=length(drug_labels);

name=['ALL_',channel_label];

drugs=textread([name,'/',name,'_drugs.txt'],'%s');
% subjects=textread([name,'/',name,'_subjects.txt'],'%s');
hrs=textread([name,'/',name,'_hrs.txt'],'%s');
fourhrs=textread([name,'/',name,'_4hrs.txt'],'%s');
states=textread([name,'/',name,'_states.txt'],'%s');
BP=load([name,'/',name,'_BP.txt']);
BP_pct=load([name,'/',name,'_BP_pct.txt']);
BP_zs=load([name,'/',name,'_BP_zs.txt']);

band_limits=[.1 4; 4 8; 10 13; 13 20; 20 50; 50 90; 90 120; 125 175];
band_labels={'delta','theta','alpha','low-beta','beta-low-gamma','mid-gamma','high-gamma','HFOs'};
long_band_labels={'Delta','Theta','Alpha','Low Beta','Beta/Low Gamma','Middle Gamma','High Gamma','HFO'};

[no_bands,~]=size(band_limits);
band_freq_labels=cell(no_bands,1); long_band_freq_labels=cell(no_bands,1);

for i=1:no_bands
    band_freq_labels{i}=[band_labels{i},num2str(band_limits(i,1)),'-',num2str(band_limits(i,2))];
    long_band_freq_labels{i}=[long_band_labels{i},' (',num2str(band_limits(i,1)),' to ',num2str(band_limits(i,2)),' Hz)'];
end

%% Plots by 4 hours and state.

p=1;
for i=1:1
    fourhr_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
    short_fourhr_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
    p=p+1;
end
for i=1:4
    fourhr_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
    short_fourhr_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
    p=p+1;
end

cplot_collected_BP_by_3_categories('Spectral Power',[name,'/',name,'_BP_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,BP)

cplot_collected_BP_by_3_categories('Power, Percent Change from Baseline',[name,'/',name,'_BP_pct_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,BP_pct)

cplot_collected_BP_by_3_categories('Power, z-Scored',[name,'/',name,'_BP_zs_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,BP_zs)

%% Plots by hour.

p=1;
for i=4:-1:1
    hr_labels{p}=['Hour ',num2str(i),' Preinjection'];
    short_hr_labels{p}=['pre',num2str(i)];
    p=p+1;
end
for i=1:12
    hr_labels{p}=['Hour ',num2str(i),' Postinjection'];
    short_hr_labels{p}=['post',num2str(i)];
    p=p+1;
end

cplot_collected_BP_by_3_categories('Spectral Power',[name,'/',name,'_BP_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,BP)

cplot_collected_BP_by_3_categories('Power, Percent Change from Baseline',[name,'/',name,'_BP_pct_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,BP_pct)
   
cplot_collected_BP_by_3_categories('Power, z-Scored',[name,'/',name,'_BP_zs_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,BP_zs)

%% Plots by 6 min.

c_order = [.5 .5 .5; 1 .75 0; 1 0 1; 0 1 1];%[1 .6 0; .6 .4 .8; .59 .29 0; .21 .37 .23];

no_pre=2; no_post=8;

[pd_labels,pd_corder]=make_period_labels(no_pre,no_post,'6mins');

lineplot_collected_BP_by_3_categories('MI, z-Scored by Hour',[name,'/',name,'_summed_hrMI_6min_by_state'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, pd_labels},drugs,states,sixmins,summed_MI,stat)

lineplot_collected_BP_by_3_categories('MI, z-Scored by Hour',[name,'/',name,'_summed_4hrMI_6min_by_state'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, pd_labels},drugs,states,sixmins,summed_MI_4hr,stat)

lineplot_collected_BP_by_categories('MI, z-Scored by Hour',[name,'/',name,'_summed_hrMI_6min'],{band_labels, band_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI,stat,c_order)

lineplot_collected_BP_by_categories('MI, z-Scored by Hour',[name,'/',name,'_summed_4hrMI_6min'],{band_labels, band_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_MI_4hr,stat,c_order)

end

