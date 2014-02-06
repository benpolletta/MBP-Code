function Satvinder_final_figs_analysis_PAC_params

% phase_lims and amp_lims are n by 2, where the first column gives the
% lower frequency limits and the second column gives the upper frequency
% limits, for phase- and amplitude-giving oscillations, respectively.

[filename,filepath]=uigetfile('*PAC_params.txt','Choose file containing collected PAC parameters.');
[statename,statepath]=uigetfile('*states.txt','Choose file containing states.');
[subjname,subjpath]=uigetfile('*subjects.txt','Choose file containing subjects.');

subjects=textread([subjpath,subjname],'%s');
states=load([statepath,statename]);
PAC_params=load([filepath,filename]);

seconds_per_epoch=10;

subj_labels={'sk47','sk48','sk49','sk50','sk51','sk52'};
% subj_labels={'sk48'};
no_subjects=length(subj_labels);

ordered_state_flags=[1 0 3 2];
state_labels={'Wake','NREM','REM','DREADD'};
no_states=length(state_labels);
state_colors={'b','g','r','m'};
state_markers={'.b','.g','.r','.m'};
state_sizes=[10 10 20 10];

hist_bins{1}=4:.25:12;
hist_bins{2}=.05:.1:1.95;
hist_bins{3}=20:5:180;
hist_bins{4}=linspace(min(PAC_params(:,1)),max(PAC_params(:,1)),100);

measure_labels={'pref_fp','pref_ph','pref_fa','maxMI'};
no_measures=length(measure_labels);
measure_titles={'Pref. Phase Freq.','Pref. Phase','Pref. Amp Freq.','Max. MI'};

for i=1:no_subjects
    
    subj_states=states(strcmp(subjects,subj_labels{i}));
    no_epochs=length(subj_states);
    t=[1:no_epochs]*seconds_per_epoch/(60*60);
    
    subj_PAC_params=PAC_params(strcmp(subjects,subj_labels{i}),:);
    
    for m=1:no_measures
        
        figure()
        
        for s=1:no_states
            
            state_flag=ordered_state_flags(s);
            
            state_indices=find(subj_states==state_flag);
            
            plot(t(state_indices),subj_PAC_params(state_indices,m),state_markers{state_flag+1},'MarkerSize',state_sizes(state_flag+1))
            
            hold on
            
        end
   
        legend(state_labels{ordered_state_flags+1})
        title([measure_titles{m},' for ',subj_labels{i}])
        xlabel('Time (hours)')
        ylabel(measure_titles{m})
        saveas(gcf,[filename(1:end-4),'_',subj_labels{i},'_',measure_labels{m},'.fig'])
        
        figure()
        
        for s=1:no_states
            
            state_flag=ordered_state_flags(s);
            
            state_indices=find(subj_states==state_flag);
            
            h=hist(subj_PAC_params(state_indices,m),hist_bins{m});
                
            plot(hist_bins{m}',h/length(state_indices),state_colors{state_flag+1})
            
            hold on
                    
        end  
                
        legend(state_labels{ordered_state_flags+1})
        title(['Distribution of ',measure_titles{m},' for ',subj_labels{i}])
        xlabel(measure_titles{m})
        ylabel('Proportion Observed')
        saveas(gcf,[filename(1:end-4),'_',subj_labels{i},'_',measure_labels{m},'_pdf.fig'])
                
        for n=(m+1):no_measures
            
            figure()
            
            for s=1:no_states

                subplot(2,2,s)
                
                state_flag=ordered_state_flags(s);
                
                state_indices=find(subj_states==state_flag);
                
                m_bins=hist_bins{m};
                n_bins=hist_bins{n};
                m_tick_indices=1:floor(length(m_bins)/10):length(m_bins);
                n_tick_indices=1:floor(length(n_bins)/10):length(n_bins);
                
                H=hist3([subj_PAC_params(state_indices,n) subj_PAC_params(state_indices,m)],{n_bins,m_bins});
                
                imagesc(H)
                axis xy
                
                set(gca,'XTick',m_tick_indices,'XTickLabel',m_bins(m_tick_indices),'YTick',n_tick_indices,'YTickLabel',n_bins(n_tick_indices))
                title([state_labels{state_flag+1},' for ',subj_labels{i}])
                xlabel(measure_titles{m})
                ylabel(measure_titles{n})
                
            end
            
            saveas(gcf,[filename(1:end-4),'_',subj_labels{i},'_',measure_labels{m},'_by_',measure_labels{m},'.fig'])
                   
        end
        
    end
    
end

clear state_indices

for m=1:no_measures
    
    figure()
    
    for s=1:no_states
        
        state_flag=ordered_state_flags(s);
        
        state_indices=find(states==state_flag);
        
        h=hist(PAC_params(state_indices,m),hist_bins{m});
        
        plot(hist_bins{m}',h/length(state_indices),state_colors{state_flag+1})
        
        hold on
        
    end
    
    legend(state_labels{ordered_state_flags+1})
    title(['Distribution of ',measure_titles{m}])
    xlabel(measure_titles{m})
    ylabel('Proportion Observed')
    saveas(gcf,[filename(1:end-4),'_',measure_labels{m},'_pdf.fig'])
        
    for n=(m+1):no_measures
        
        figure()
        
        for s=1:no_states
            
            subplot(2,2,s)
            
            state_flag=ordered_state_flags(s);
            
            state_indices=find(states==state_flag);
            
            m_bins=hist_bins{m};
            n_bins=hist_bins{n};
            m_tick_indices=1:floor(length(m_bins)/10):length(m_bins);
            n_tick_indices=1:floor(length(n_bins)/10):length(n_bins);
            
            H=hist3([PAC_params(state_indices,n) PAC_params(state_indices,m)],{n_bins,m_bins});
            
            imagesc(H)
            axis xy
            
            set(gca,'XTick',m_tick_indices,'XTickLabel',m_bins(m_tick_indices),'YTick',n_tick_indices,'YTickLabel',n_bins(n_tick_indices))
            title(state_labels{state_flag+1})
            xlabel(measure_titles{m})
            ylabel(measure_titles{n})
            
        end
        
        saveas(gcf,[filename(1:end-4),'_',measure_labels{m},'_by_',measure_labels{m},'.fig'])
        
    end
    
end