function plot_Freqs_Bernat(channel_name,measure)

load('f_bins.mat')

load('AP_freqs.mat')

name=sprintf('ALL_%s',channel_name);

load([name,'/',name,'_',measure,'_freqs.mat'])

hr_bins{1} = linspace(min(hr_params(:,1)),max(hr_params(:,1)),100);
hr_bins{2} = phase_freqs;
hr_bins{3} = amp_freqs;
hr_names = {'Max. IE','Pref. f_p','Pref. f_a'};

no_bands = size(bands,1);

band_bins = cell(2*no_bands,1);
band_names = cell(2*no_bands,1);

for b = 1:no_bands
    
    band_bins{2*b-1} = [];
    
    band_bins{2*b} = f_bins(bands(b,1) <= f_bins & f_bins <= bands(b,2));
    
    band_names{2*b-1} = sprintf('%g - %g Hz Power',bands(b,1),bands(b,2));
    
    band_names{2*b-1} = sprintf('%g - %g Hz Peak Freq.',bands(b,1),bands(b,2));
    
end

% subjects=text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
IE_drugs=text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
IE_hrs=text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
IE_fourhrs=text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
IE_states=text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
    
drugs=text_read([name,'/',name,'_drugs.txt'],'%s');
hrs=text_read([name,'/',name,'_hrs.txt'],'%s');
fourhrs=text_read([name,'/',name,'_4hrs.txt'],'%s');
sixmins=text_read([name,'/',name,'_6mins.txt'],'%s');
states=text_read([name,'/',name,'_states.txt'],'%s');

long_state_labels={'Wake','NREM','REM'};
state_labels={'W','NR','R'};
drug_labels={'saline','MK801','NVP','Ro25'};

%% Plots by 4 Hours.

no_pre=1; no_post=4; no_4hrs=no_pre+no_post;
fourhr_labels=cell(no_4hrs,1); short_fourhr_labels=cell(no_4hrs,1); fourhr_corder=zeros(no_4hrs,3);

p=1;
for i=1:no_pre
    fourhr_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
    short_fourhr_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
    fourhr_corder(p,:)=(p-1)*[1 1 1]/(2*no_pre);
    p=p+1;
end
for i=1:no_post
    fourhr_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
    short_fourhr_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
    fourhr_corder(p,:)=(i-1)*[0 1 1]/no_post+(no_post-i)*[1 0 1]/no_post;
    p=p+1;
end

% State-dependent only.

hist_collected_freqs_by_3_categories('Inverse Entropy',[name,'/',name,'_IE_hr_params_4hrs_by_state'],hr_bins,hr_names,fourhr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_fourhr_labels, fourhr_labels},IE_drugs,IE_states,IE_fourhrs,hr_params)

hist_collected_freqs_by_3_categories('Spectral Power',[name,'/',name,'_spec_params_4hrs_by_state'],band_bins,band_names,fourhr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,spec_params)

hist_collected_freqs_by_3_categories('Power, Percent Change from Baseline',[name,'/',name,'_spec_pct_params_4hrs_by_state'],band_bins,band_names,fourhr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,spec_pct_params)

hist_collected_freqs_by_3_categories('Power, z-Scored',[name,'/',name,'_spec_zs_params_4hrs_by_state'],band_bins,band_names,fourhr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,spec_zs_params)

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

hist_collected_freqs_by_categories('Inverse Entropy',[name,'/',name,'_IE_hr_params_hrs'],hr_bins,hr_names,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},IE_drugs,IE_hrs,hr_params)

hist_collected_freqs_by_categories('Spectral Power',[name,'/',name,'_spec_params_hrs'],band_bins,band_names,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,spec_params)

hist_collected_freqs_by_categories('Power, Percent Change from Baseline',[name,'/',name,'_spec_pct_params_hrs'],band_bins,band_names,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,spec_pct_params)

hist_collected_freqs_by_categories('Power, z-Scored',[name,'/',name,'_spec_zs_params_hrs'],band_bins,band_names,hr_corder,{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,spec_zs_params)

% State-dependent.

hist_collected_freqs_by_3_categories('Inverse Entropy',[name,'/',name,'_IE_hr_params_hrs_by_state'],hr_bins,hr_names,hr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_hr_labels, hr_labels},IE_drugs,IE_states,IE_hrs,hr_params)

hist_collected_freqs_by_3_categories('Spectral Power',[name,'/',name,'_spec_params_hrs_by_state'],band_bins,band_names,hr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,spec_params)

hist_collected_freqs_by_3_categories('Power, Percent Change from Baseline',[name,'/',name,'_spec_pct_params_hrs_by_state'],band_bins,band_names,hr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,spec_pct_params)
   
hist_collected_freqs_by_3_categories('Power, z-Scored',[name,'/',name,'_spec_zs_params_hrs_by_state'],band_bins,band_names,hr_corder,{drug_labels, drug_labels},{state_labels, long_state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,spec_zs_params)

end