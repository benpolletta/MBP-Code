function All_bp_plots_Bernat(drug,channel_label)

subjects={'A99','A102','A103','A104','A105','A106'};
subj_num=length(subjects);

state_labels={'W','NR','R'};
no_states=length(state_labels);

name=['ALL_',drug,'_',channel_label];

subjects=textread([name,'_subjects.txt'],'%s');
hrs=textread([name,'_hrs.txt'],'%s');
fourhrs=textread([name,'_4hrs.txt'],'%s');
states=textread([name,'_states.txt'],'%s');
BP=load([name,'_BP.txt']);
BP_pct=load([name,'_BP_pct.txt']);

band_limits=[.1 4; 4 8; 10 13; 13 20; 20 50; 50 90; 90 120; 125 175];
band_labels={'delta','theta','alpha','low-beta','beta-low-gamma','mid-gamma','high-gamma','HFOs'};
long_band_labels={'Delta','Theta','Alpha','Low Beta','Beta/Low Gamma','Middle Gamma','High Gamma','HFO'};

[no_bands,~]=size(band_limits);

for i=1:no_bands
    band_freq_labels{i}=[band_labels{i},num2str(band_limits(i,1)),'-',num2str(band_limits(i,2))];
    long_band_freq_labels{i}=[long_band_labels{i},' (',num2str(band_limits(i,1)),' to ',num2str(band_limits(i,2)),' Hz)'];
end

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
% no_4hrs=length(fourhr_labels);
% 
% cplot_collected_BP_by_categories(drug,[name,'_BP_4hrs_by_state'],{band_freq_labels, long_band_freq_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},states,fourhrs,BP)
% 
% cplot_collected_BP_by_categories([drug,' Percent from Baseline'],[name,'_BP_pct_4hrs_by_state'],{band_freq_labels, long_band_freq_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},states,fourhrs,BP_pct)

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
no_hrs=length(hr_labels);

cplot_collected_BP_by_categories(drug,[name,'_BP_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},states,hrs,BP)

cplot_collected_BP_by_categories([drug,' Percent from Baseline'],[name,'_BP_pct_hrs_by_state'],{band_freq_labels, long_band_freq_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},states,hrs,BP_pct)
    
end

