function All_PLV_plots_by_subject(channel_label1, channel_label2, norms, state_flag, period_flag)

load('AP_freqs.mat')
freqs = [phase_freqs amp_freqs];
% no_freqs = length(freqs);

bands = [20 200; 1 12];
band_names = {'20 - 200 Hz', '1 - 12 Hz'};

stops = [];%[58 62; 117 123; 179 181];

subj_labels = load('subjects.mat'); subj_labels = subj_labels.subjects;
subj_num = length(subj_labels);

state_labels = load('states.mat'); state_labels = state_labels.states;
% no_states=length(state_labels);

drug_labels = load('drugs.mat'); drug_labels = drug_labels.drugs;
% no_drugs=length(drug_labels);

PLV_dir = sprintf('ALL_%s_by_%s_PLV', channel_label1, channel_label2);

drugs = text_read([PLV_dir,'/',PLV_dir(1:end-4),'_drugs.txt'],'%s');
subjects = text_read([PLV_dir,'/',PLV_dir(1:end-4),'_subjects.txt'],'%s');
periods = text_read([PLV_dir,'/',PLV_dir(1:end-4), '_', period_flag, '.txt'], '%s');
states = text_read([PLV_dir,'/',PLV_dir(1:end-4),'_states.txt'],'%s');

if strcmp(period_flag, 'hrs')
    
    no_pre = 4; no_post = 20;
    
elseif strcmp(period_flag, '4hrs')
    
    no_pre = 1; no_post = 4;
    
elseif strcmp(period_flag, '6mins')
    
    no_pre = 2; no_post = 8;
    
end

[pd_labels, pd_corder, long_pd_labels] = make_period_labels(no_pre, no_post, period_flag);

no_norms = length(norms);

for s = 1:subj_num
    
    subj_label = subj_labels{s};
    
    subj_indices = strcmp(subjects, subj_label);
    
    subj_drugs = drugs(subj_indices);
    
    subj_states = states(subj_indices);
    
    subj_periods = periods(subj_indices);
    
    for n = 1:no_norms
        
        title = [subj_label, ', PLV', norms{n}, ')'];
        
        if strcmp(state_flag, 'state')
            
            if strcmp(norms{n}, '_thresh_pct')
                
                PLV_name = [PLV_dir, '/', PLV_dir(1:(end - 4)), '_PLV', norms{n}, '_by_state.mat'];
                
                PLV_data = load(PLV_name); PLV_data = PLV_data.PLV_pct;
                
            else
                
                PLV_name = [PLV_dir, '/', PLV_dir(1:(end - 4)), '_PLV', norms{n}, '.txt'];
                
                PLV_data = load(PLV_name);
                
            end
            
            subj_PLV_data = PLV_data(subj_indices, :);
            
            cplot_collected_spec_by_3_categories(title,[PLV_dir,'/',PLV_dir(1:end-4),'_',subj_label,'_PLV',norms{n},'_',period_flag,'_by_state'],...
                freqs,bands,band_names,stops,pd_corder,...
                {drug_labels, drug_labels},{state_labels, state_labels},{pd_labels, long_pd_labels},...
                subj_drugs,subj_states,subj_periods,subj_PLV_data)
            
        else
            
            PLV_name = [PLV_dir, '/', PLV_dir(1:(end - 4)), '_PLV', norms{n}, '.txt'];
            
            PLV_data = load(PLV_name);
            
            subj_PLV_data = PLV_data(subj_indices, :);
            
            cplot_collected_spec_by_categories(title,[PLV_dir,'/',PLV_dir(1:end-4),'_',subj_label,'_PLV',norms{n},'_',period_flag],...
                freqs,bands,band_names,stops,pd_corder,...
                {drug_labels, drug_labels},{pd_labels, long_pd_labels},...
                subj_drugs,subj_periods,subj_PLV_data)
            
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

