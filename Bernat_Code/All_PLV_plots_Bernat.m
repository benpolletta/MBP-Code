function All_PLV_plots_Bernat(channel_label1,channel_label2)

load('AP_freqs.mat')
freqs = [phase_freqs amp_freqs];
% no_freqs = length(freqs);

bands=[20 200; 1 12];
band_names={'20 - 200 Hz','1 - 12 Hz'};

stops=[];%[58 62; 117 123; 179 181];

% subjects={'A99','A102','A103','A104','A105','A106'};
% subj_num=length(subjects);

state_labels={'W','NR','R'};
% no_states=length(state_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
% no_drugs=length(drug_labels);

dir=sprintf('ALL_%s_by_%s_PLV',channel_label1,channel_label2);

drugs = text_read([dir,'/',dir(1:end-4),'_drugs.txt'],'%s');
% subjects = text_read([dir,'/',dir(1:end-4),'_subjects.txt'],'%s');
hrs = text_read([dir,'/',dir(1:end-4),'_hrs.txt'],'%s');
% fourhrs = text_read([dir,'/',dir(1:end-4),'_4hrs.txt'],'%s');
sixmins = text_read([dir,'/',dir(1:end-4),'_6mins.txt'],'%s');
states = text_read([dir,'/',dir(1:end-4),'_states.txt'],'%s');
PLV = load([dir,'/',dir(1:end-4),'_PLV.txt']);
PLV_thresh = load([dir,'/',dir(1:end-4),'_PLV_thresh.txt']);
PP = load([dir,'/',dir(1:end-4),'_PP.txt']);

titles = {'Phase-Locking Value','z-Scored Phase-Locking Value','Preferred Phase'};

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
% cplot_collected_spec_by_3_categories(titles{1},[dir,'/',dir(1:end-4),'_PLV_hrs_by_state'],freqs,bands,band_names,stops,fourhr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,PLV)
% 
% cplot_collected_spec_by_3_categories(titles{2},[dir,'/',dir(1:end-4),'_PLV_thresh_hrs_by_state'],freqs,bands,band_names,stops,fourhr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,PLV_thresh)
% 
% cplot_collected_spec_by_3_categories(titles{3},[dir,'/',dir(1:end-4),'_PP_hrs_by_state'],freqs,bands,band_names,stops,fourhr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,PP)

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

% cplot_collected_spec_by_categories(titles{1},[dir,'/',dir(1:end-4),'_PLV_hrs'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PLV)
% 
% cplot_collected_spec_by_categories(titles{2},[dir,'/',dir(1:end-4),'_PLV_thresh_hrs'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PLV_thresh)
% 
% cplot_collected_spec_by_categories(titles{3},[dir,'/',dir(1:end-4),'_PP_hrs'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PP)

% State-dependent.

cplot_collected_spec_by_3_categories(titles{1},[dir,'/',dir(1:end-4),'_PLV_hrs_by_state'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PLV)

cplot_collected_spec_by_3_categories(titles{2},[dir,'/',dir(1:end-4),'_PLV_thresh_hrs_by_state'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PLV_thresh)
   
cplot_collected_spec_by_3_categories(titles{3},[dir,'/',dir(1:end-4),'_PP_hrs_by_state'],freqs,bands,band_names,stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PP)

% cplot_collected_spec_by_3_categories_3_14(titles{1},[dir,'/',dir(1:end-4),'_PLV_hrs_by_state'],freqs,stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PLV)
% 
% cplot_collected_spec_by_3_categories_3_14(titles{2},[dir,'/',dir(1:end-4),'_PLV_thresh_hrs_by_state'],freqs,stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PLV_thresh)
%    
% cplot_collected_phase_by_3_categories_3_14(titles{3},[dir,'/',dir(1:end-4),'_PP_hrs_by_state'],freqs,stops,hr_corder,{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PP)


%% Plots by 6 Minute Periods.

no_pre=4; no_post=12;

[pd_labels,pd_corder]=make_period_labels(no_pre,no_post,'6mins');

% State-independent only.

cplot_collected_spec_by_categories(titles{1},[dir,'/',dir(1:end-4),'_PLV_6mins'],freqs,bands,band_names,stops,pd_corder,{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,PLV)

cplot_collected_spec_by_categories(titles{2},[dir,'/',dir(1:end-4),'_PLV_thresh_6mins'],freqs,bands,band_names,stops,pd_corder,{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,PLV_thresh)

cplot_collected_phase_by_categories(titles{3},[dir,'/',dir(1:end-4),'_PP_6mins'],freqs,bands,band_names,stops,pd_corder,{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,PP)

end

