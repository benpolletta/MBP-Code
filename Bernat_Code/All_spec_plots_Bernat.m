function All_spec_plots_Bernat(channel_label)

freqs=1000*[1:2^10]/2^11;
freqs=freqs(freqs<=200);

bands=[100 200; 20 100; 4 12];
band_names={'HFO','gamma','theta'};

stops=[58 62; 117 123; 179 181];

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
sixmins=textread([name,'/',name,'_6mins.txt'],'%s');
states=textread([name,'/',name,'_states.txt'],'%s');
spec=load([name,'/',name,'_spec.txt']);
spec_pct=load([name,'/',name,'_spec_pct.txt']);
spec_zs=load([name,'/',name,'_spec_zs.txt']);

%% Plots by 4 Hours.

% no_pre=1; no_post=4; no_4hrs=no_pre+no_post;
% fourhr_labels=cell(no_4hrs,1); short_fourhr_labels=cell(no_4hrs,1); fourhr_corder=zeros(no_4hrs,3);
% 
% p=1;
% for i=1:no_pre
%     fourhr_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
%     short_fourhr_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
%     fourhr_corder(p,:)=(p-1)*[1 1 1]/(2*no_pre);
%     p=p+1;
% end
% for i=1:no_post
%     fourhr_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
%     short_fourhr_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
%     fourhr_corder(p,:)=(i-1)*[0 1 1]/no_post+(no_post-i)*[1 0 1]/no_post;
%     p=p+1;
% end
% 
% % State-dependent only.
% 
% cplot_collected_spec_by_3_categories('Spectral Power',[name,'/',name,'_spec_hrs_by_state'],freqs,bands,band_names,stops,fourhr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,spec)
% 
% cplot_collected_spec_by_3_categories('Power, Percent Change from Baseline',[name,'/',name,'_spec_pct_hrs_by_state'],freqs,[0 200],'',stops,fourhr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,spec_pct)
% 
% cplot_collected_spec_by_3_categories('Power, z-Scored',[name,'/',name,'_spec_zs_hrs_by_state'],freqs,[0 200],'',stops,fourhr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,spec_zs)

%% Plots by Hour.

no_pre=4; no_post=12; no_hrs=no_pre+no_post;
hr_labels=cell(no_hrs,1); short_hr_labels=cell(no_hrs,1); hr_corder=zeros(no_hrs,3);

p=1;
for i=no_pre:-1:1
    hr_labels{p}=['Hour ',num2str(i),' Preinjection'];
    short_hr_labels{p}=['pre',num2str(i)];
    hr_corder(p,:)=(p-1)*[1 1 1]/(2*no_pre);
    p=p+1;
end
for i=1:no_post
    hr_labels{p}=['Hour ',num2str(i),' Postinjection'];
    short_hr_labels{p}=['post',num2str(i)];
    hr_corder(p,:)=(i-1)*[0 1 1]/no_post+(no_post-i)*[1 0 1]/no_post;
    p=p+1;
end

% State-independent.

cplot_collected_spec_by_categories('Spectral Power',[name,'/',name,'_spec_hrs'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,spec)

cplot_collected_spec_by_categories('Power, Percent Change from Baseline',[name,'/',name,'_spec_pct_hrs'],freqs,[0 200],'',stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,spec_pct)

cplot_collected_spec_by_categories('Power, z-Scored',[name,'/',name,'_spec_zs_hrs'],freqs,[0 200],'',stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,spec_zs)

% State-dependent.

% cplot_collected_spec_by_3_categories('Spectral Power',[name,'/',name,'_spec_hrs_by_state'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,spec)
% 
% cplot_collected_spec_by_3_categories('Power, Percent Change from Baseline',[name,'/',name,'_spec_pct_hrs_by_state'],freqs,[0 200],'',stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,spec_pct)
%    
% cplot_collected_spec_by_3_categories('Power, z-Scored',[name,'/',name,'_spec_zs_hrs_by_state'],freqs,[0 200],'',stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,spec_zs)

%% Plots by 6 Minute Periods.
% 
% no_pre=4; no_post=12;
% 
% [pd_labels,pd_corder]=make_period_labels(no_pre,no_post,'6mins');
% 
% % State-independent only.
% 
% cplot_collected_spec_by_categories('Spectral Power',[name,'/',name,'_spec_6mins'],freqs,bands,band_names,stops,pd_corder,{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,spec)
% 
% cplot_collected_spec_by_categories('Power, Percent Change from Baseline',[name,'/',name,'_spec_pct_6mins'],freqs,[0 200],'',stops,pd_corder,{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,spec_pct)
% 
% cplot_collected_spec_by_categories('Power, z-Scored',[name,'/',name,'_spec_zs_6mins'],freqs,[0 200],'',stops,pd_corder,{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,spec_zs)

end

