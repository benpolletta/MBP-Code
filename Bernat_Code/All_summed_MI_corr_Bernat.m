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

state_labels={'W','NR','R'};
no_states=length(state_labels);

long_state_labels={'Active Wake','NREM / Quiet Wake','REM'};

%% Setting up information about periods (time since injection).

hours_plotted=-4:16;
hours_plotted(hours_plotted==0)=[];

[period_colors,hr_periods]=make_period_labels(4,16,'hrs');
no_periods=length(hr_periods);
% period_colors=[max(linspace(-1,1,no_periods)',0) max(linspace(1,-1,no_periods)',0) ones(no_periods,1)];

% sampling_freq=1000;
% seconds_per_epoch=4096/250;
% epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

%% Setting up arrays to store outputs of correlation analysis.

All_corrs=nan(no_band_pairs,no_periods,no_states,no_drugs);
All_lines=nan(no_band_pairs,2,no_periods,no_states,no_drugs);

%% Cycling through drugs.

for d=1:no_drugs
    
    drug=drug_labels{d};
    
    drug_summed_MI=summed_MI(strcmp(drugs,drug),:);
    %         drug_summed_MI_4hr=subj_summed_MI_4hr(strcmp(subj_drugs,drug),:);
    drug_states=states(strcmp(drugs,drug));
    drug_hrs=hrs(strcmp(drugs,drug));
    %     drug_4hrs=fourhrs(strcmp(drugs,drug));
    
    for h=1:no_periods
        
        pd_summed_MI=drug_summed_MI(strcmp(drug_hrs,hr_periods{h}),:);
        %             pd_summed_MI_4hr=drug_summed_MI_4hr(epochs,:);
        pd_states=drug_states(strcmp(drug_hrs,hr_periods{h}));
        %             pd_hrs=drug_hrs(epochs);
        %             pd_4hrs=drug_hrs(epochs);
        
        %% Normalizing summed MI.
        %
        %         pd_summed_MI_mean=ones(size(pd_summed_MI))*diag(nanmean(pd_summed_MI));
        %         pd_summed_MI_std=ones(size(pd_summed_MI))*diag(nanstd(pd_summed_MI));
        %         pd_summed_MI_norm=(pd_summed_MI-pd_summed_MI_mean)./pd_summed_MI_std;
        
        for s=1:no_states
            
            state_label=state_labels{s};
            
            state_indices=find(strcmp(pd_states,state_label));
            
            if length(state_indices)>=2
                
                state_abscissa=pd_summed_MI(state_indices,band_pairs(:,1));
                state_ordinate=pd_summed_MI(state_indices,band_pairs(:,2));
                
                state_corr=corr(state_abscissa,state_ordinate);
                
                All_corrs(:,h,s,d)=diag(state_corr);
                
                for p=1:no_band_pairs
                    
                    fit=polyfit(state_abscissa(:,p),state_ordinate(:,p),1);
                    
                    All_lines(p,:,h,s,d)=fit;
                    
                end
                
            end
            
        end
        
    end
    
end

for p=1:no_band_pairs
    
    figure(p)
    
    for d=1:no_drugs
        
        subplot(no_drugs,1,d)
            
        plot(hours_plotted',reshape(All_corrs(p,:,:,d),no_periods,no_states),'-s')
        
        axis('tight')
        
        if d==1
            
            legend(state_labels)
                
            title({channel_label;[band_pair_labels{p},' Summed MI']})
            
        end
        
        if d==no_drugs
            
            xlabel('Hour Since Injection')
            
        end
        
        ylabel(drug_labels{d})
             
    end
    
    saveas(gcf,[all_dirname,'/',all_dirname,'_',band_pair_labels{p},'_by_drug.fig'])
    
    set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
    
    print(gcf,'-dpdf',[all_dirname,'/',all_dirname,'_',band_pair_labels{p},'_by_drug.pdf'])
    
end