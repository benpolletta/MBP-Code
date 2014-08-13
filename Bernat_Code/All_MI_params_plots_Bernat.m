function All_MI_params_plots_Bernat(channel_label, measure, freq_measure, stat)

state_labels={'W','NR','R'};
% no_states=length(state_labels);

drug_labels={'saline','MK801','NVP','Ro25'};
% no_drugs=length(drug_labels);

name=['ALL_',channel_label];

drugs = text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects = text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
hrs = text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhrs = text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
sixmins = text_read([name,'/',name,'_',measure,'_6min_periods.txt'],'%s');
states = text_read([name,'/',name,'_',measure,'_states.txt'],'%s');

load([name, '/', name, '_', measure, '_MI_params.mat'])

if strcmp(freq_measure, 'max')
    
    long_measure_labels = {'Max. MI', 'Pref. Phase Freq.', 'Pref. Amp. Freq.'};
    measure_labels = {'maxMI', 'pref_fp', 'pref_fa'};
    hr_params = hr_params_max;
    
elseif strcmp(freq_measure, 'mean')
    
    long_measure_labels = {'Pref. Phase Freq.', 'Pref. Amp. Freq.'};
    measure_labels = {'pref_fp', 'pref_fa'};
    hr_params = hr_params_mean;
    
end
    
no_measures=length(measure_labels);

%% Barplots by 4 hr period.

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
% 
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour',[name,'/',name,'_summed_MI_hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_MI)
% 
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name,'_summed_MI_4hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_MI_4hr)

%% Barplots by hr period.

% p=1;
% for i=4:-1:1
%     hr_labels{p}=['Hour ',num2str(i),' Preinjection'];
%     short_hr_labels{p}=['pre',num2str(i)];
%     p=p+1;
% end
% for i=1:12
%     hr_labels{p}=['Hour ',num2str(i),' Postinjection'];
%     short_hr_labels{p}=['post',num2str(i)];
%     p=p+1;
% end
% 
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour',[name,'/',name,'_summed_MI_hr_by_hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,summed_MI)
% 
% cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name,'_summed_MI_4hr_by_hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,summed_MI_4hr)

%% Lineplots by 6 min period.

no_pre=4; no_post=12;

[pd_labels, ~]=make_period_labels(no_pre,no_post,'6mins');

lineplot_collected_BP_by_3_categories('MI Parameters',[name,'/',name,'_MI_params_6min_by_state'],{measure_labels, long_measure_labels},{drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, pd_labels},drugs,states,sixmins,hr_params,stat)

c_order = [.5 .5 .5; 1 .75 0; 1 0 1; 0 1 1];%[1 .49 0; .6 .4 .8; .59 .29 0; .21 .37 .23];

lineplot_collected_BP_by_categories('MI Parameters',[name,'/',name,'_MI_params_6min'],{measure_labels, long_measure_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,hr_params,stat,c_order)

end

