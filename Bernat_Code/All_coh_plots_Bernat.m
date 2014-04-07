function All_coh_plots_Bernat(channel_label1,channel_label2)

freqs=1000*[0:2^13]/2^14;
freqs=freqs(freqs<=200);

bands=[4 12; 20 100; 100 200];
band_names={'theta','gamma','HFO'};

stops=[58 62; 118 122; 179 181];

% subjects={'A99','A102','A103','A104','A105','A106'};
% subj_num=length(subjects);

state_labels={'W','NR','R'};
% no_states=length(state_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
% no_drugs=length(drug_labels);

name=['All_',channel_label1,'_by_',channel_label2,'_cohy'];

drugs=textread([name,'/',name,'_drugs.txt'],'%s');
% subjects=textread([name,'/',name,'_subjects.txt'],'%s');
hrs=textread([name,'/',name,'_hrs.txt'],'%s');
% fourhrs=textread([name,'/',name,'_4hrs.txt'],'%s');
% states=textread([name,'/',name,'_states.txt'],'%s');
coh=load([name,'/',name,'_coh.txt']);
icoh=load([name,'/',name,'_icoh.txt']);
rcoh=load([name,'/',name,'_rcoh.txt']);

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

cplot_collected_spec_by_categories('Coherence, z-Scored',[name,'/',name,'_coh_hrs'],freqs,[0 200],'',stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,coh)

cplot_collected_spec_by_categories('Imaginary Coherence, z-Scored',[name,'/',name,'_icoh_hrs'],freqs,[0 200],'',stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,icoh)

cplot_collected_spec_by_categories('Real Coherence, z-Scored',[name,'/',name,'_rcoh_hrs'],freqs,[0 200],'',stops,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,rcoh)

end

