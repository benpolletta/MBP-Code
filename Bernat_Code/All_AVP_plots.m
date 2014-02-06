function All_AVP_plots(channel_label,phase_freq,norm_flag)

amps=20:5:200; phases=-.95:.1:.95;
matrix_rows=length(amps); matrix_columns=length(phases);

name=['ALL_',channel_label];

if norm_flag==1
    
    AVP_name=[name,'/',name,'_AVP_p',num2str(phase_freq),'_norm'];

elseif norm_flag==0
    
    AVP_name=[name,'/',name,'_AVP_p',num2str(phase_freq)];  
    
else
    
    display('norm_flag must be zero or one.')
    
    return
    
end

subjects=textread([name,'/',name,'_AVP_p',num2str(phase_freq),'_subjects.txt'],'%s');
drugs=textread([name,'/',name,'_AVP_p',num2str(phase_freq),'_drugs.txt'],'%s');
hr_periods=textread([name,'/',name,'_AVP_p',num2str(phase_freq),'_hr_periods.txt'],'%s');
fourhr_periods=textread([name,'/',name,'_AVP_p',num2str(phase_freq),'_4hr_periods.txt'],'%s');
states=textread([name,'/',name,'_AVP_p',num2str(phase_freq),'_states.txt'],'%s');
AVP=load([AVP_name,'.txt']);
    
long_state_labels={'Wake','NREM','REM'};
state_labels={'W','NR','R'};
no_states=length(state_labels);

subj_labels={'A99','A102','A103','A104','A105','A106'};
no_subjects=length(subj_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
no_drugs=length(drug_labels);

fig_dir=AVP_name;
mkdir (fig_dir)

%% Figures by hour.

% p=1;
% for i=4:-1:1
%     period_labels{p}=['Hour ',num2str(i),' Preinjection'];
%     short_period_labels{p}=['pre',num2str(i)];
%     p=p+1;
% end
% for i=1:12
%     period_labels{p}=['Hour ',num2str(i),' Postinjection'];
%     short_period_labels{p}=['post',num2str(i)];
%     p=p+1;
% end
% 
% for d=1:no_drugs
% 
%     cplot_collected_AVP_by_categories([fig_dir,'/',name,'_AVP_p',num2str(phase_freq),'_',drug_labels{d}],4,4,amps,phases,{drug_labels(d), drug_labels(d)},{short_period_labels, period_labels},drugs,hr_periods,AVP,norm_flag)
% 
% end
%     
% %%%%%%%%%%%%%%%%%%%%% FIGURES BY SUBJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for s=1:no_subjects
%     
%     subject=char(subj_labels{s});
%     
%     subj_AVP=AVP(strcmp(subjects,subject),:);
%     
%     subj_drugs=drugs(strcmp(subjects,subject),:);
%     
%     subj_states=states(strcmp(subjects,subject),:);
%     
%     subj_periods=hr_periods(strcmp(subjects,subject),:);
%     
%     for d=1:no_drugs
%     
%         cplot_collected_AVP_by_categories([fig_dir,'/',name,'_AVP_p',num2str(phase_freq),'_',subject,'_',drug_labels{d}],4,4,amps,phases,{drug_labels(d), drug_labels(d)},{short_period_labels, period_labels},subj_drugs,subj_periods,subj_AVP,norm_flag)
%     
%     end
%         
% end

%% Figures by state and 4 hour period.

clear period_labels; p=1;
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

cplot_collected_AVP_by_3_categories([fig_dir,'/',name,'_AVP_p',num2str(phase_freq)],no_states,no_periods,amps,phases,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},drugs,states,fourhr_periods,AVP,norm_flag)

%%%%%%%%%%%%%%%%%%%%% FIGURES BY SUBJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s=1:no_subjects
    
    subject=char(subj_labels{s});
    
    subj_AVP=AVP(strcmp(subjects,subject),:);
    
    subj_drugs=drugs(strcmp(subjects,subject),:);
    
    subj_states=states(strcmp(subjects,subject),:);
    
    subj_periods=fourhr_periods(strcmp(subjects,subject),:);
    
    cplot_collected_AVP_by_3_categories([fig_dir,'/',name,'_AVP_p',num2str(phase_freq),'_',subject],no_states,no_periods,amps,phases,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_period_labels, period_labels},subj_drugs,subj_states,subj_periods,subj_AVP,norm_flag)
    
end