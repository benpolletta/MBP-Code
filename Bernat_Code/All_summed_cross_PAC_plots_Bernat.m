function All_summed_cross_PAC_plots_Bernat(channel_label1, channel_label2, stat, norms, state_flag, period_flag)

state_labels={'W','NR','R'};

drug_labels={'saline','MK801','NVP','Ro25'};

name = sprintf('ALL_%s_A_by_%s_P_PAC', channel_label1, channel_label2);
title_name = sprintf('%s Amp. by %s Phase, ', channel_label1, channel_label2);

drugs = text_read([name, '/', name(1:end-4), '_drugs.txt'], '%s');
%subjects = text_read([name, '/', name(1:end-4), '_subjects.txt'], '%s');
periods = text_read([name, '/', name(1:end-4), '_', period_flag, '.txt'], '%s');
states = text_read([name, '/', name(1:end-4), '_states.txt'], '%s');

if strcmp(period_flag, 'hrs')
    
    no_pre = 4; no_post = 20;
    
elseif strcmp(period_flag, '4hrs')
    
    no_pre = 1; no_post = 4;
    
elseif strcmp(period_flag, '6mins')
    
    no_pre = 2; no_post = 8;
    
end

[pd_labels, ~, long_pd_labels] = make_period_labels(no_pre, no_post, period_flag);

no_norms = length(norms);

for n = 1:no_norms
    
    load([name, '/', name, norms{n}, '_summed.mat'])
    
    if strcmp(state_flag, 'state')
        
        lineplot_collected_BP_by_3_categories([title_name, ' PAC',norms{n}],[name,'/',name(1 : end - 4),'_summed_PAC',norms{n},'_',period_flag,'_by_state'],{band_labels, band_labels},...
            {drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, long_pd_labels},drugs,states,periods,summed_MI,stat)
        
    else
        
        c_order = [.5 .5 .5; 1 .75 0; 1 0 1; 0 1 1]; %[1 .6 0; .6 .4 .8; .59 .29 0; .21 .37 .23];
        
        lineplot_collected_BP_by_categories([title_name, ' PAC',norms{n}],[name,'/',name(1 : end - 4),'_summed_PAC',norms{n},'_',period_flag],{band_labels, band_labels},...
            {drug_labels, drug_labels},{pd_labels, long_pd_labels},drugs,periods,summed_MI,stat,c_order)
        
    end
    
end

end

% %% Barplots by 4 hr period.
% 
% % p=1;
% % for i=1:1
% %     fourhr_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
% %     short_fourhr_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
% %     p=p+1;
% % end
% % for i=1:4
% %     fourhr_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
% %     short_fourhr_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
% %     p=p+1;
% % end
% % 
% % cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour'],[name,'/',name(1 : end - 4),'_summed_PLV_hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_PLV)
% % 
% % cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name(1 : end - 4),'_summed_MI_4hr_by_4hr'],{band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_fourhr_labels, fourhr_labels},drugs,states,fourhrs,summed_MI_4hr)
% 
% %% Lineplots by hr period.
% 
% [hr_labels, short_hr_labels] = deal(cell(24, 1));
% 
% p=1;
% for i=4:-1:1
%     hr_labels{p}=['Hour ',num2str(i),' Preinjection'];
%     short_hr_labels{p}=['pre',num2str(i)];
%     p=p+1;
% end
% for i=1:20
%     hr_labels{p}=['Hour ',num2str(i),' Postinjection'];
%     short_hr_labels{p}=['post',num2str(i)];
%     p=p+1;
% end
% 
% % "Raw" summed PLV.
% 
% lineplot_collected_BP_by_3_categories([title_name, ' PLV'],[name,'/',name(1 : end - 4),'_summed_PLV_hr_by_state'],{band_labels, band_labels},...
%     {drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,summed_PLV,stat)
% 
% lineplot_collected_BP_by_categories([title_name, ' PLV'],[name,'/',name(1 : end - 4),'_summed_PLV_hr'],{band_labels, band_labels},...
%     {drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,summed_PLV,stat,c_order)
% 
% % Summed PLV as a percentage of baseline.
% 
% lineplot_collected_BP_by_3_categories([title_name, ' PLV, Pct. Change from Baseline'],[name,'/',name(1 : end - 4),'_summed_PLV_pct_hr_by_state'],...
%     {band_labels, band_labels},{drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,summed_PLV_pct,stat)
% 
% lineplot_collected_BP_by_categories([title_name, ' PLV, Pct. Change from Baseline'],[name,'/',name(1 : end - 4),'_summed_PLV_pct_hr'],...
%     {band_labels, band_labels},{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,summed_PLV_pct,stat,c_order)
% 
% %% Lineplots by 6 min period.