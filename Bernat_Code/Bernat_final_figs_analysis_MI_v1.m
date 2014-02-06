function Bernat_final_figs_analysis_MI_v1(measure_suffix,channel_label)

filename=['ALL_',channel_label,'_',measure_suffix];

subjects=textread([filename,'_subjects.txt'],'%s');
drugs=textread([filename,'_drugs.txt'],'%s');
hr_periods=textread([filename,'_hr_periods.txt'],'%s');
fourhr_periods=textread([filename,'_4hr_periods.txt'],'%s');
states=textread([filename,'_states.txt'],'%s');
MI=load([filename,'_hr_MI.txt']);
MI_4hr=load([filename,'_4hr_MI.txt']);

x_ticks=1:.25:12; y_ticks=20:5:200;
matrix_rows=length(y_ticks); matrix_columns=length(x_ticks);

p=1;
for i=4:-1:1
    long_hr_labels{p}=['Hour ',num2str(i),' Preinjection'];
    hr_labels{p}=['pre',num2str(i)];
    p=p+1;
end
for i=1:12
    long_hr_labels{p}=['Hour ',num2str(i),' Postinjection'];
    hr_labels{p}=['post',num2str(i)];
    p=p+1;
end
no_hrs=length(hr_labels);

p=1;
for i=1:1
    long_fourhr_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
    fourhr_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
    p=p+1;
end
for i=1:3
    long_fourhr_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
    fourhr_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
    p=p+1;
end
no_fourhrs=length(hr_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
no_drugs=length(drug_labels);

long_state_labels={'Wake','NREM','REM'};
state_labels={'W','NR','R'};
no_states=length(state_labels);

subj_labels={'A99','A102','A103','A104','A105','A106'};
no_subjects=length(subj_labels);

stat_labels={'median','mean','std'};
long_stat_labels={'Median','Mean','St. Dev.'};
no_stats=length(stat_labels);

fig_dir=filename;
mkdir (fig_dir)

measure_name=[fig_dir,'/',filename];

%%%%%%%%%%%%%%% FIGURES BY HOUR, STATE VS. 4HR, PER DRUG %%%%%%%%%%%%%%%%%%

close('all')

figs=[];

for d=1:no_drugs
    
    drug=char(drug_labels{d});
    
    drugs_drug=drugs(strcmp(drugs,drug));
    
    hrs_drug=hr_periods(strcmp(drugs,drug));
    
    fourhrs_drug=fourhr_periods(strcmp(drugs,drug));
    
    MI_drug=MI(strcmp(drugs,drug),:);
    
    MI_4hr_drug=MI_4hr(strcmp(drugs,drug),:);

    cplot_collected_MI_by_categories(measure_name,4,4,x_ticks,y_ticks,{{drug},{drug}},{hr_labels, long_hr_labels},drugs_drug,hrs_drug,MI_drug)

    cplot_collected_MI_by_categories(measure_name,3,4,x_ticks,y_ticks,{state_labels, long_state_labels},{fourhr_labels, long_fourhr_labels},states_drug,fourhrs_drug,MI_4hr_drug)
    
    cplot_collected_MI_by_categories([measure_name,'_hr'],3,4,x_ticks,y_ticks,{state_labels, long_state_labels},{fourhr_labels, long_fourhr_labels},states_drug,fourhrs_drug,MI_drug)
    
end

%%%%%%%%%%%%%%%%%%%%% FIGURES BY DRUG VS. 4HR, PER STATE %%%%%%%%%%%%%%%%%%

for s=1:no_states
    
    state=char(state_labels{d});
    
%     states_state=states(strcmp(states,state));
    
    drugs_state=drugs(strcmp(states,state));
    
%     hrs_state=hr_periods(strcmp(states,state));
    
    fourhrs_state=fourhr_periods(strcmp(states,state));
    
    MI_state=MI(strcmp(states,state),:);
    
    MI_4hr_state=MI_4hr(strcmp(states,state),:);

%     cplot_collected_MI_by_categories(measure_name,4,4,x_ticks,y_ticks,{{state},{state}},{hr_labels, long_period_labels},states_state,hrs_state,MI_state)

    cplot_collected_MI_by_categories(measure_name,4,4,x_ticks,y_ticks,{drug_labels, drug_labels},{fourhr_labels, long_fourhr_labels},drugs_state,fourhrs_state,MI_4hr_state)
    
    cplot_collected_MI_by_categories([measure_name,'_hr'],4,4,x_ticks,y_ticks,{drug_labels, drug_labels},{fourhr_labels, long_fourhr_labels},drugs_state,fourhrs_state,MI_state)
    
end


%%%%%%%%%%%%%%%%%%%%% FIGURES BY SUBJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s=1:no_subjects
    
    subject=char(subj_labels{s});
    
    subj_states=states(strcmp(subjects,subject),:);
    
%     subj_hrs=hr_periods(strcmp(subjects,subject),:);
    
    subj_4hrs=fourhr_periods(strcmp(subjects,subject),:);
    
    subj_MI=MI(strcmp(subjects,subject),:);
    
    subj_MI_4hrs=MI_4hr(strcmp(subjects,subject),:);
    
    cplot_collected_MI_by_categories(measure_name,3,4,x_ticks,y_ticks,{state_labels, long_state_labels},{fourhr_labels, long_fourhr_labels},subj_states,subj_4hrs,subj_MI_4hrs)
    
    cplot_collected_MI_by_categories([measure_name],4,4,x_ticks,y_ticks,{drug_labels, drug_labels},{fourhr_labels, long_fourhr_labels},subj_drugs,subj_4hrs,subj_MI_4hrs)
   
    cplot_collected_MI_by_categories([measure_name,'_hr'],3,4,x_ticks,y_ticks,{state_labels, long_state_labels},{fourhr_labels, long_fourhr_labels},subj_states,subj_4hrs,subj_MI)
    
    cplot_collected_MI_by_categories([measure_name,'_hr'],4,4,x_ticks,y_ticks,{drug_labels, drug_labels},{fourhr_labels, long_fourhr_labels},subj_drugs,subj_4hrs,subj_MI)

end