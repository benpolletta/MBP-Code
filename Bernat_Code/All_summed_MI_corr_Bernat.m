function All_summed_MI_corr_Bernat(channel_label,measure)

close('all')

%% Loading summed MI.

name=['ALL_',channel_label];

drugs=textread([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects=textread([name,'/',name,'_',measure,'_subjects.txt'],'%s');
hrs=textread([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhrs=textread([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
states=textread([name,'/',name,'_',measure,'_states.txt'],'%s');
summed_struct=load([name,'/',name,'_',measure,'_summed.mat']);
band_labels=summed_struct.band_labels;
no_bands=length(band_labels);
summed_MI=summed_struct.summed_MI;
% summed_MI_4hr=summed_struct.summed_MI_4hr;
clear summed_struct

%% Setting up directory to save files.

all_dirname=['ALL_',channel_label];
mkdir (all_dirname)

%% Setting up pairs of bands.

band_pairs=nchoosek(1:no_bands,2);
no_band_pairs=size(band_pairs,1);
band_pair_labels=cell(1,no_band_pairs);
for p=1:no_band_pairs
    band_pair_labels{p}=[band_labels{band_pairs(p,1)},'-vs-',band_labels{band_pairs(p,2)}];
end

%% Working with different drugs.

drug_labels={'saline','MK801','NVP','Ro25'};
no_drugs=length(drug_labels);

%% Setting up information about different states.

state_labels={'R','NR','W'};
no_states=length(state_labels);

long_state_labels={'REM','NREM / Quiet Wake','Active Wake'};

states_rearranged=[2 3 1];

%% Setting up information about periods (time since injection).

% hours_plotted=[-4 16];

hr_periods=make_period_labels(4,16,'hrs');
no_periods=length(hr_periods);
period_colors=[max(linspace(-1,1,no_periods)',0) max(linspace(1,-1,no_periods)',0) ones(no_periods,1)];

% sampling_freq=1000;
% seconds_per_epoch=4096/250;
% epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

%% Cycling through drugs.

for d=1:no_drugs
    
    drug=drug_labels{d};
    
    drug_summed_MI=summed_MI(strcmp(drugs,drug),:);
    %         drug_summed_MI_4hr=subj_summed_MI_4hr(strcmp(subj_drugs,drug),:);
    drug_states=states(strcmp(drugs,drug));
    drug_hrs=hrs(strcmp(drugs,drug));
%     drug_4hrs=fourhrs(strcmp(drugs,drug));
    
    for f=1:no_periods
        
        pd_summed_MI=drug_summed_MI(strcmp(drug_hrs,hr_periods{f}),:);
        %             pd_summed_MI_4hr=drug_summed_MI_4hr(epochs,:);
        pd_states=drug_states(strcmp(drug_hrs,hr_periods{f}));
        %             pd_hrs=drug_hrs(epochs);
        %             pd_4hrs=drug_hrs(epochs);
        
        %             total_epochs=length(epochs);
        
        %% Normalizing summed MI.
        
        pd_summed_MI_mean=ones(size(pd_summed_MI))*diag(nanmean(pd_summed_MI));
        pd_summed_MI_std=ones(size(pd_summed_MI))*diag(nanstd(pd_summed_MI));
        pd_summed_MI_norm=(pd_summed_MI-pd_summed_MI_mean)./pd_summed_MI_std;
        
        %             summed_MI_max(d,:)=nanmax(pd_summed_MI);
        
        %% PLOTTING FIGURES
        
        %% Each band, all drugs, by 4 hour period.
        
        for p=1:no_band_pairs

            figure(p)
            
            for s_r=1:no_states
                
                subplot(no_drugs,no_states,(d-1)*no_states+s_r)
                
                state_index=states_rearranged(s_r);
                
                state_label=state_labels{state_index};
                
                state_indices=find(strcmp(pd_states,state_label));
                
                plot(pd_summed_MI_norm(state_indices,band_pairs(p,1)),pd_summed_MI_norm(state_indices,band_pairs(p,2)),'.','Color',period_colors(f,:))
                
                hold on
                
                axis('tight')
                
                if d==1 && s_r==round(no_states/2)
                    
                    try
                        
                        title({channel_label;[band_pair_labels{p},' Summed MI']})
                        
                    end
                    
                end
                
                if d==no_drugs
                    
                    xlabel(long_state_labels{state_index})
                    
                end
                
                if f==1
                    
                    ylabel(drug)
                    
                end
                
            end
            
        end
        
    end
    
end

for p=1:no_band_pairs
    
    figure(p)
    
    subplot(no_drugs,no_states,round(no_states/2))
    legend(hr_periods)
    
    saveas(gcf,[all_dirname,'/',all_dirname,'_',band_pair_labels{p},'.fig'])
    
    set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
    
    print(gcf,'-dpdf',[all_dirname,'/',all_dirname,'_',band_pair_labels{p},'.pdf'])
    
end

close('all')