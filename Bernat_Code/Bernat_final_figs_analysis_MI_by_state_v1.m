function Bernat_final_figs_analysis_MI_by_state_v1

x_ticks=1:.25:12; y_ticks=20:5:200;
matrix_rows=length(y_ticks); matrix_columns=length(x_ticks);

[filename,filepath]=uigetfile('*by_state_MI.txt','Choose file containing collected MI.');
[periodname,periodpath]=uigetfile('*by_state_periods.txt','Choose file containing periods.');
[statename,statepath]=uigetfile('*by_state_states.txt','Choose file containing states.');
[subjname,subjpath]=uigetfile('*by_state_subjects.txt','Choose file containing subjects.');

MI=load([filepath,filename]);
% [rows,cols]=size(MI);
periods=textread([periodpath,periodname],'%s');
states=textread([statepath,statename],'%s');
subjects=textread([subjpath,subjname],'%s');

p=1;
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

long_state_labels={'Wake','NREM','REM'};
state_labels={'W','NR','R'};
no_states=length(state_labels);

subj_labels={'A99','A102','A103','A104','A105','A106'};
no_subjects=length(subj_labels);

fig_dir=filename(1:end-7);
mkdir (fig_dir)

%%%%%%%%%%%%%%%%%%% TOTAL FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cplot_collected_MI_by_categories([fig_dir,'/',fig_dir],no_states,no_periods,x_ticks,y_ticks,{state_labels, long_state_labels},{short_period_labels, period_labels},states,periods,MI)

%%%%%%%%%%%%%%%%%%%%% FIGURES BY SUBJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s=1:no_subjects
    
    subject=char(subj_labels{s});
    
    subj_MI=MI(strcmp(subjects,subject)==1,:);
    
    subj_states=states(strcmp(subjects,subject)==1,:);
    
    subj_periods=periods(strcmp(subjects,subject)==1,:);
    
    cplot_collected_MI_by_categories([fig_dir,'/',fig_dir,'_',subject],no_states,no_periods,x_ticks,y_ticks,{state_labels, long_state_labels},{short_period_labels, period_labels},subj_states,subj_periods,subj_MI)
    
end