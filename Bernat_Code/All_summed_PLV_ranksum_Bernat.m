function All_summed_PLV_ranksum_Bernat(channel_label1, channel_label2, norms, state_flag, period_flag)

% Period flag must be one of 'hrs', '4hrs', or '6mins'.

state_labels={'W','NR','R'};

drug_labels={'saline','MK801','NVP','Ro25'};

name = sprintf('ALL_%s_by_%s_PLV', channel_label1, channel_label2);

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
    
    if strcmp(state_flag, 'state_vs_W')
            
        load([name, '/', name, '_summed.mat'])
        
        eval(['PLV_data = summed_PLV', norms{n}, ';'])
        
        stats_collected_BP_by_3_categories([name,'/',name(1 : end - 4),'_summed_PLV',norms{n},'_',period_flag,'_',state_flag],{band_labels, band_labels},...
            {drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, long_pd_labels},drugs,states,periods,PLV_data)
    
    elseif strcmp(state_flag, 'state')
        
        if strcmp(norms{n}, '_thresh_pct')
            
            load([name, '/', name, '_summed.mat'], 'band_labels')
            
            PLV_name = [name, '/', name(1:(end - 4)), '_PLV', norms{n}, '_by_state.mat'];
            
            PLV_data = load(PLV_name); PLV_data = PLV_data.summed_PLV_pct;
            
        else
            
            load([name, '/', name, '_summed.mat'])
            
            eval(['PLV_data = summed_PLV', norms{n}, ';'])
            
        end
        
        stats_collected_BP_by_3_categories([name,'/',name(1 : end - 4),'_summed_PLV',norms{n},'_',period_flag,'_by_state'],{band_labels, band_labels},...
            {state_labels, state_labels},{drug_labels, drug_labels},{pd_labels, long_pd_labels},states,drugs,periods,PLV_data)
        
    else
            
        load([name, '/', name, '_summed.mat'])
        
        eval(['PLV_data = summed_PLV', norms{n}, ';'])
        
        stats_collected_BP_by_categories([name,'/',name(1 : end - 4),'_summed_PLV',norms{n},'_',period_flag],{band_labels, band_labels},...
            {drug_labels, drug_labels},{pd_labels, long_pd_labels},drugs,periods,PLV_data)
        
    end
    
end

end

% % Summed PLV as a percentage of baseline.
% 
% stats_collected_BP_by_3_categories([name,'/',name(1 : end - 4),'_summed_PLV_pct_6min_by_state'],{band_labels, band_labels},...
%     {state_labels, state_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},states,drugs,sixmins,summed_PLV_pct)
% 
% stats_collected_BP_by_categories([name,'/',name(1 : end - 4),'_summed_PLV_pct_6min'],{band_labels, band_labels},{drug_labels, drug_labels},{pd_labels, pd_labels},drugs,sixmins,summed_PLV_pct)
% 
% end

% %% Ranksums by 4 hr period.
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
% % cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by Hour'],[name,'/',name(1 : end - 4),'_summed_PLV_hr_by_4hr'],{band_labels, band_labels},{state_labels, state_labels},{drug_labels, drug_labels},{short_fourhr_labels, fourhr_labels},states,drugs,fourhrs,summed_PLV)
% % 
% % cplot_collected_BP_by_3_categories('Modulation Index, z-Scored by State Every 4 Hrs',[name,'/',name(1 : end - 4),'_summed_MI_4hr_by_4hr'],{band_labels, band_labels},{state_labels, state_labels},{drug_labels, drug_labels},{short_fourhr_labels, fourhr_labels},states,drugs,fourhrs,summed_MI_4hr)
% 
% %% Ranksums by hr period.
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
% stats_collected_BP_by_3_categories([name,'/',name(1 : end - 4),'_summed_PLV_hr_by_state'],{band_labels, band_labels},...
%     {state_labels, state_labels},{drug_labels, drug_labels},{short_hr_labels, hr_labels},states,drugs,hrs,summed_PLV)
% 
% % stats_collected_BP_by_categories([name,'/',name(1 : end - 4),'_summed_PLV_hr'],{band_labels, band_labels},{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,summed_PLV)
% 
% % Summed PLV as a percentage of baseline.
% 
% stats_collected_BP_by_3_categories([name,'/',name(1 : end - 4),'_summed_PLV_pct_hr_by_state'],{band_labels, band_labels},...
%     {state_labels, state_labels},{drug_labels, drug_labels},{short_hr_labels, hr_labels},states,drugs,hrs,summed_PLV_pct)
% 
% % stats_collected_BP_by_categories([name,'/',name(1 : end - 4),'_summed_PLV_pct_hr'],{band_labels, band_labels},{drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,summed_PLV_pct)
% 
% %% Ranksums by 6 min period.
% 
% no_pre=2; no_post=8;
