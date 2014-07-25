function All_summed_MI_plots_by_subject_Bernat(channel_label,measure)

close('all')

%% Loading summed MI.

name=['ALL_',channel_label];

drugs=text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subjects=text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
% hrs=text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhrs=text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
states=text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
summed_struct=load([name,'/',name,'_',measure,'_summed.mat']);
band_labels=summed_struct.band_labels;
no_bands=length(band_labels);
summed_MI=summed_struct.summed_MI;
% summed_MI_4hr=summed_struct.summed_MI_4hr;
clear summed_struct

%% Setting up directory to save files.

all_dirname=['ALL_',channel_label];
mkdir (all_dirname)

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

% sampling_freq=1000;
seconds_per_epoch=4096/250;
% epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

%% Cycling through subjects.

subject_labels={'A99','A102','A103','A104','A105','A106'};

for s=1:6
    
    subject=subject_labels{s};
    
    subj_summed_MI=summed_MI(strcmp(subjects,subject),:);
    % subj_summed_MI_4hr=summed_MI_4hr(strcmp(subjects,subject),:);
    subj_drugs=drugs(strcmp(subjects,subject));
    subj_states=states(strcmp(subjects,subject));
    % subj_hrs=hrs(strcmp(subjects,subject));
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
    
    summed_MI_max=zeros(no_drugs,no_bands);
    
    inj_epoch = nan(no_drugs, 1);
    start_epoch = nan(no_drugs, 1);
    end_epoch = nan(no_drugs, 1);
    
    for d=1:no_drugs
        
        drug=drug_labels{d};
        
        drug_summed_MI=subj_summed_MI(strcmp(subj_drugs,drug),:);
        % drug_summed_MI_4hr=subj_summed_MI_4hr(strcmp(subj_drugs,drug),:);
        drug_states=subj_states(strcmp(subj_drugs,drug));
        % drug_hrs=subj_hrs(strcmp(subj_drugs,drug));
        drug_4hrs=subj_4hrs(strcmp(subj_drugs,drug));
        
        inj_epoch(d)=find(strcmp(drug_4hrs,'post1to4'), 1 );
        start_epoch(d)=find(strcmp(drug_4hrs,'pre4to1'), 1 );
        end_epoch(d)=find(strcmp(drug_4hrs,'post13to16'), 1, 'last' );
        
        epochs=start_epoch(d):end_epoch(d);
        inj_epoch(d)=inj_epoch(d)-start_epoch(d);
        
        drug_summed_MI=drug_summed_MI(epochs,:);
        % drug_summed_MI_4hr=drug_summed_MI_4hr(epochs,:);
        drug_states=drug_states(epochs);
        % drug_hrs=drug_hrs(epochs);
        % drug_4hrs=drug_4hrs(epochs);
        
        total_epochs=length(epochs);
        t=((1:total_epochs)-inj_epoch(d))*seconds_per_epoch/(60*60);
        
        %% Normalizing summed MI.
        
        % drug_summed_MI_mean=ones(size(drug_summed_MI))*diag(nanmean(drug_summed_MI));
        % drug_summed_MI_std=ones(size(drug_summed_MI))*diag(nanstd(drug_summed_MI));
        % drug_summed_MI_norm=(drug_summed_MI-drug_summed_MI_mean)./drug_summed_MI_std;
        drug_summed_MI_norm = zscore(drug_summed_MI);
        
        summed_MI_max(d,:)=nanmax(drug_summed_MI);
        
        %% PLOTTING FIGURES
        
        %% All bands, all drugs.
        
        figure((s-1)*(no_bands+1)+1)
        
        subplot(4,1,d)
        
        imagesc(drug_summed_MI_norm')
        axis xy
        colorbar
        x_ticks=1:floor(total_epochs/5):total_epochs;
        set(gca,'XTick',x_ticks,'XTickLabel',round(t(x_ticks)))
        y_ticks=1:no_bands;
        set(gca,'YTick',y_ticks,'YTickLabel',band_labels)
        
        if d==1

            try
                
                title({[subject,', ',char(channel_label)];'Normalized Summed MI'})
            
            catch error
                
                display(error.msg)
                
            end
            
        end
        
        xlabel('Time (h)')
        ylabel({drug;'Frequency (Hz)'})
        
%         %% All bands, each drug.
%         
%         figure(1+d)
%         
%         imagesc(drug_summed_MI_norm')
%         axis xy
%         colorbar
%         x_ticks=1:floor(total_epochs/5):total_epochs;
%         set(gca,'XTick',x_ticks,'XTickLabel',t(x_ticks))
%         y_ticks=1:no_bands;
%         set(gca,'YTick',y_ticks,'YTickLabel',band_freq_labels_long)
%         
%         title({[subject,', Channel ',num2str(channel),', ',drug];'Normalized Band Power'})
%         
%         xlabel('Time (h)')
%         ylabel('Frequency (Hz)')
%         
%         saveas(gcf,[all_dirname,'/',all_filename,'_',drug,'_bands.fig'])
        
        %% Each band, all drugs, by epoch.
        
        for b=1:no_bands
            
%             figure(2*no_drugs+1+b)
            figure((s-1)*(no_bands+1)+1+b)
            
            subplot(4,1,d)
            
            for s_r=1:no_states
                
                state_index=states_rearranged(s_r);
                
                state_indices=find(strcmp(drug_states,state_labels{state_index}));
                
                plot(t(state_indices),drug_summed_MI(state_indices,b),state_markers{state_index},'MarkerSize',state_sizes(state_index))
                
                hold on
                
            end
            
            if d==1
                
                legend(state_labels{states_rearranged})
                
                try
                
                    title({[subject,', ',char(channel_label)];[band_labels{b},' Summed MI']})
                    
                catch error
                    
                    display(error.msg)
                
                end
                    
            end
            
            if d==no_drugs
                
                xlabel('Time (h)')
                
            end
            
            ylabel(drug)
            
%             %% Each band, each drug, by epoch.
%             
%             figure(no_drugs+1+d*no_bands+b)
%             
%             for s_r=1:no_states
%                 
%                 s=states_rearranged(s_r);
%                 
%                 state_indices=find(strcmp(drug_epoch_states,states{s}));
%                 
%                 plot(t(state_indices),drug_summed_MI(state_indices,b),state_markers{s},'MarkerSize',state_sizes(s))
%                 
%                 hold on
%                 
%             end
%             
%             plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
%             
%             legend(state_labels)
%             title({[subject,', Channel ',num2str(channel),', ',drug];[band_labels{b},' Power']})
%             xlabel('Time (h)')
%             ylabel([band_freq_labels{b},' Power'])
%             
%             saveas(gcf,[all_dirname,'/',all_filename,'_',drug,'_',band_freq_labels{b},'.fig'])
            
        end
        
    end
    
    %% ADDING VERTICAL BAR AT INJECTION EPOCH.
    
    for b=1:no_bands
        
%         figure(2*no_drugs+1+b)
        figure((s-1)*(no_bands+1)+1+b)
        
        for d=1:no_drugs
            
            subplot(4,1,d)
            
            ylim([0 summed_MI_max(d,b)])
            
            plot([0 0],ylim,'k','LineWidth',2)
            
            xlim([-4 16])
            
            hold off
            
        end
        
        saveas(gcf,[all_dirname,'/',subject,'_',channel_label,'_',band_labels{b},'.pdf'])
        
        subplot(4,1,1)
        
        legend(state_labels{states_rearranged})
        
        saveas(gcf,[all_dirname,'/',subject,'_',channel_label,'_',band_labels{b},'.fig'])
        
    end
    
end