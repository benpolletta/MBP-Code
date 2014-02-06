function All_summed_MI_plots_Bernat(channel_label,measure)

% subjects={'A99','A102','A103','A104','A105','A106'};
% subj_num=length(subjects);

state_labels={'W','NR','R'};
% no_states=length(state_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
% no_drugs=length(drug_labels);

name=['ALL_',channel_label];

drugs=textread([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects=textread([name,'/',name,'_',measure,'_subjects.txt'],'%s');
hrs=textread([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhrs=textread([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
states=textread([name,'/',name,'_',measure,'_states.txt'],'%s');
load([name,'/',name,'_',measure,'_summed.mat']);

no_bands=length(band_labels);

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

cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour',[name,'/',name,'_summed_MI_hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_MI)

cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name,'_summed_MI_4hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_MI_4hr)

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

cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour',[name,'/',name,'_summed_MI_hr_by_hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,summed_MI)

cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name,'_summed_MI_4hr_by_hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,summed_MI_4hr)

end

