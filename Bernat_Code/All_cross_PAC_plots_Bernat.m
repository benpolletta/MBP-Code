function All_cross_PAC_plots_Bernat(channel_label1, channel_label2, norms, state_flag, period_flag)

load('AP_freqs.mat')
% no_freqs = length(freqs);

% subjects={'A99','A102','A103','A104','A105','A106'};
% subj_num=length(subjects);

state_labels = {'W', 'NR', 'R'};
% no_states=length(state_labels);

drug_labels = {'saline', 'MK801', 'NVP', 'Ro25'};
no_drugs=length(drug_labels);

dir = sprintf('ALL_%s_A_by_%s_P_PAC', channel_label1, channel_label2);

drugs = text_read([dir,'/',dir(1:end-4),'_drugs.txt'],'%s');
% subjects = text_read([dir,'/',dir(1:end-4),'_subjects.txt'],'%s');
periods = text_read([dir,'/',dir(1:end-4), '_', period_flag, '.txt'], '%s');
states = text_read([dir,'/',dir(1:end-4),'_states.txt'],'%s');

if strcmp(period_flag, 'hrs')
    
    if strcmp(state_flag, 'state')
    
        no_pre = 2; no_post = 8;
        
        rows = 3; cols = 10;
        
    else
        
        no_pre = 4; no_post = 12;
        
        rows = 4; cols = 4;
    
    end
        
elseif strcmp(period_flag, '4hrs')
    
    if strcmp(state_flag, 'state')
    
        no_pre = 4; no_post = 16;
    
        rows = 3; cols = 5;
        
    else
        
        no_pre = 8; no_post = 24;
        
        rows = 2; cols = 4;
    
    end
    
elseif strcmp(period_flag, '6mins')
    
    if strcmp(state_flag, 'state')
    
        no_pre = .5; no_post = 1;
    
        rows = 3; cols = 15;
        
    else
        
        no_pre = 1; no_post = 3;
        
        rows = 7; cols = 7;
    
    end
    
end

[pd_labels, ~, long_pd_labels] = make_period_labels(no_pre, no_post, period_flag);

no_norms = length(norms);

for n = 1:no_norms
    
    title = ['Cross-Structure PAC (PAC', norms{n}, ')'];
    
    PAC_name = [dir, '/', dir, norms{n}, '.txt'];
    
    PAC_data = load(PAC_name);
    
    for d = 1:no_drugs
        
        if strcmp(state_flag, 'state')
            
            cplot_collected_MI_by_3_categories([dir,'/',dir(1:end-4),'_PAC',norms{n},'_',period_flag,'_by_state_',drug_labels{d}],rows,cols,phase_freqs,amp_freqs,...
                {drug_labels(d), drug_labels(d)},{state_labels, state_labels},{pd_labels, long_pd_labels},drugs,states,periods,PAC_data)
            
        else
            
            cplot_collected_MI_by_categories([dir,'/',dir(1:end-4),'_PAC',norms{n},'_',period_flag,'_',drug_labels{d}],rows,cols,phase_freqs,amp_freqs,...
                {drug_labels(d), drug_labels(d)},{pd_labels, long_pd_labels},drugs,periods,PAC_data)
            
        end
        
    end
    
end

end

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

% no_pre=4; no_post=12; no_hrs=no_pre+no_post;
% hr_labels=cell(no_hrs,1); short_hr_labels=cell(no_hrs,1); hr_corder=zeros(no_hrs,3);
% 
% p=1;
% for i=no_pre:-1:1
%     hr_labels{p}=['Hour ',num2str(i),' Preinjection'];
%     short_hr_labels{p}=['pre',num2str(i)];
%     hr_corder(p,:)=(p-1)*[1 1 1]/(2*no_pre);
%     p=p+1;
% end
% for i=1:no_post
%     hr_labels{p}=['Hour ',num2str(i),' Postinjection'];
%     short_hr_labels{p}=['post',num2str(i)];
%     hr_corder(p,:)=(i-1)*[0 1 1]/no_post+(no_post-i)*[1 0 1]/no_post;
%     p=p+1;
% end
% 
% % State-independent.
% 
% cplot_collected_spec_by_categories(titles{1},[dir,'/',dir(1:end-4),'_PLV_hrs'],freqs,bands,band_names,stops,hr_corder,...
%     {drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PLV)
% 
% cplot_collected_spec_by_categories(titles{2},[dir,'/',dir(1:end-4),'_PLV_thresh_hrs'],freqs,bands,band_names,stops,hr_corder,...
%     {drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PLV_thresh)
% 
% cplot_collected_spec_by_categories(titles{3},[dir,'/',dir(1:end-4),'_PLV_zs_hrs'],freqs,bands,band_names,stops,hr_corder,...
%     {drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PLV_zs)
% 
% cplot_collected_spec_by_categories(titles{4},[dir,'/',dir(1:end-4),'_PLV_pct_hrs'],freqs,bands,band_names,stops,hr_corder,...
%     {drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PLV_pct)
% 
% cplot_collected_spec_by_categories(titles{3},[dir,'/',dir(1:end-4),'_PP_hrs'],freqs,bands,band_names,stops,hr_corder,...
%     {drug_labels, drug_labels},{short_hr_labels, hr_labels},drugs,hrs,PP)
% 
% % State-dependent.
% 
% cplot_collected_spec_by_3_categories_3_14(titles{1},[dir,'/',dir(1:end-4),'_PLV_hrs_by_state'],freqs,stops,hr_corder,...
%     {drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PLV)
% 
% cplot_collected_spec_by_3_categories_3_14(titles{2},[dir,'/',dir(1:end-4),'_PLV_thresh_hrs_by_state'],freqs,stops,hr_corder,...
%     {drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PLV_thresh)
%    
% cplot_collected_phase_by_3_categories_3_14(titles{3},[dir,'/',dir(1:end-4),'_PP_hrs_by_state'],freqs,stops,hr_corder,...
%     {drug_labels, drug_labels},{state_labels, state_labels},{short_hr_labels, hr_labels},drugs,states,hrs,PP)

