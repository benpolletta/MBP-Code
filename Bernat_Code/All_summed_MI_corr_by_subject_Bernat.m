function All_summed_MI_corr_by_subject_Bernat(channel_label,measure)

close('all')

%% Loading summed MI.

name=['ALL_',channel_label];

drugs=textread([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects=textread([name,'/',name,'_',measure,'_subjects.txt'],'%s');
% hrs=textread([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
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

% long_state_labels={'REM','NREM / Quiet Wake','Active Wake'};
state_markers={'.r','.g','.b'};
state_sizes=[20 10 10];

states_rearranged=[2 3 1];

%% Setting up information about periods (time since injection).

% hours_plotted=[-4 16];

fourhr_periods={'pre4to1','post1to4','post5to8','post9to12','post13to16'};
no_4hr_periods=length(fourhr_periods);

% sampling_freq=1000;
% seconds_per_epoch=4096/250;
% epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

%% Cycling through subjects.

subject_labels={'A99','A102','A103','A104','A105','A106'};

for s=1:6
    
    subject=subject_labels{s};
    
    subj_summed_MI=summed_MI(strcmp(subjects,subject),:);
%     subj_summed_MI_4hr=summed_MI_4hr(strcmp(subjects,subject),:);
    subj_drugs=drugs(strcmp(subjects,subject));
    subj_states=states(strcmp(subjects,subject));
%     subj_hrs=hrs(strcmp(subjects,subject));
    subj_4hrs=fourhrs(strcmp(subjects,subject));
    
    %     if strcmp(subject,'A99') || strcmp(subject,'A102')
    %         inj_epochs=floor([3*60 5*60+7 2*60+35 5*60+7]*epochs_per_min);
    %         number_epochs=[7354 4938 5236 4881];
    %     elseif strcmp(subject,'A103') || strcmp(subject,'A104')
    %         inj_epochs=[813 733 1293 1125];
    %         number_epochs=[5449 4782 5703 5107];
    %     elseif strcmp(subject,'A105') || strcmp(subject,'A106')
    %         inj_epochs=floor([5*60+7 4*60+42 2*60+53 5*60+7]*epochs_per_min);
    %         number_epochs=[4313 5006 4541 5736];
    %     end
    
%     summed_MI_max=zeros(no_drugs,no_bands);
    
    for d=1:no_drugs
        
        drug=drug_labels{d};
        
        drug_summed_MI=subj_summed_MI(strcmp(subj_drugs,drug),:);
%         drug_summed_MI_4hr=subj_summed_MI_4hr(strcmp(subj_drugs,drug),:);
        drug_states=subj_states(strcmp(subj_drugs,drug));
%         drug_hrs=subj_hrs(strcmp(subj_drugs,drug));
        drug_4hrs=subj_4hrs(strcmp(subj_drugs,drug));
        
        for f=1:no_4hr_periods
            
            start_epoch=find(strcmp(drug_4hrs,fourhr_periods{f}), 1 );
            end_epoch=find(strcmp(drug_4hrs,fourhr_periods{f}), 1, 'last' );
            
            epochs=start_epoch:end_epoch;
            
            pd_summed_MI=drug_summed_MI(epochs,:);
%             pd_summed_MI_4hr=drug_summed_MI_4hr(epochs,:);
            pd_states=drug_states(epochs);
%             pd_hrs=drug_hrs(epochs);
%             pd_4hrs=drug_4hrs(epochs);
            
%             total_epochs=length(epochs);
            
            %% Normalizing summed MI.
            
            pd_summed_MI_mean=ones(size(pd_summed_MI))*diag(nanmean(pd_summed_MI));
            pd_summed_MI_std=ones(size(pd_summed_MI))*diag(nanstd(pd_summed_MI));
            pd_summed_MI_norm=(pd_summed_MI-pd_summed_MI_mean)./pd_summed_MI_std;
            
%             summed_MI_max(d,:)=nanmax(pd_summed_MI);
            
            %% PLOTTING FIGURES
            
            %% Each band, all drugs, by 4 hour period.
            
            for p=1:no_band_pairs
                
                %             figure(2*no_drugs+1+b)
                figure((s-1)*(no_band_pairs+1)+1+p)
                
                subplot(no_drugs,no_4hr_periods,(d-1)*no_4hr_periods+f)
                
                for s_r=1:no_states
                    
                    state_index=states_rearranged(s_r);
                    
                    state_indices=find(strcmp(pd_states,state_labels{state_index}));
                    
                    plot(pd_summed_MI_norm(state_indices,band_pairs(p,1)),pd_summed_MI_norm(state_indices,band_pairs(p,2)),state_markers{state_index},'MarkerSize',state_sizes(state_index))
                    
                    hold on
                    
                end
                
                axis('tight')
                
                if d==1 && f==round(no_4hr_periods/2)
                    
                    legend(state_labels{states_rearranged})
                    
                    try
                        
                        title({[subject,', ',char(channel_label)];[band_pair_labels{p},' Summed MI']})
                        
                    end
                    
                end
                
                if d==no_drugs
                    
                    xlabel(fourhr_periods{f})
                    
                end
                
                if f==1
                
                    ylabel(drug)
                    
                end
                
            end
            
        end
        
    end
    
    for p=1:no_band_pairs
        
        figure((s-1)*(no_band_pairs+1)+1+p)
        
        saveas(gcf,[all_dirname,'/',subject,'_',channel_label,'_',band_pair_labels{p},'.fig'])
        
        set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
        
        print(gcf,'-dpdf',[all_dirname,'/',subject,'_',channel_label,'_',band_pair_labels{p},'.pdf'])
    
    end
    
    close('all')
        
end