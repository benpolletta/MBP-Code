function [MI_sum]=Satvinder_time_course_figs(phase_lims,amp_lims,subjects,states,MI)

% phase_lims and amp_lims are n by 2, where the first column gives the
% lower frequency limits and the second column gives the upper frequency
% limits, for phase- and amplitude-giving oscillations, respectively.

if isempty(phase_lims) && isempty(amp_lims)
    
    no_als=0;
    
else

    [no_als,al_cols]=size(amp_lims);
    
    if al_cols~=2
        if no_als==2
            amp_lims=amp_lims';
            [no_als,~]=size(amp_lims);
        else
            display('amp_lims must be n by 2, where the first column gives the lower frequency limits and the second column gives the upper frequency limits.')
            return
        end
    end
    
    [no_pls,pl_cols]=size(phase_lims);
    
    if pl_cols~=2
        if no_pls==2
            phase_lims=phase_lims';
            [no_pls,~]=size(amp_lims);
        else
            display('phase_lims must be n by 2, where the first column gives the lower frequency limits and the second column gives the upper frequency limits.')
            return
        end
    end
    
    if no_pls~=no_als
        display('phase_lims and amp_lims must be the same size.')
        return
    end

end

[filename,filepath]=uigetfile('*MI.txt','Choose file containing collected MI.');
% [statename,statepath]=uigetfile('*states.txt','Choose file containing states.');
% [subjname,subjpath]=uigetfile('*subjects.txt','Choose file containing subjects.');

% tic; subjects=textread([subjpath,subjname],'%s'); toc;
% tic; states=load([statepath,statename]); toc;
% tic; MI=load([filepath,filename]); toc;

seconds_per_epoch=10;

subj_labels={'sk47','sk48','sk49','sk50','sk51','sk52'};
% subj_labels={'sk48'};
no_subjects=length(subj_labels);

ordered_state_flags=[1 0 3 2];
state_labels={'Wake','NREM','REM','DREADD'};
no_states=length(state_labels);
state_markers={'.b','.g','.r','.m'};
state_sizes=[10 10 20 10];

bands_lo=4:.25:12;
no_phases=length(bands_lo);
bands_hi=20:5:180;
no_amps=length(bands_hi);

measure_labels={'maxMI','maxfp','maxfa'};
no_measures=length(measure_labels);
measure_titles={'Max. MI','Max. Phase Freq.','Max. Amp. Freq.'};

if no_als>0
    MI_sum=zeros(length(MI),no_als);
    mean_MI_sum=zeros(no_states,no_als);
    std_MI_sum=zeros(no_states,no_als);
end

% for i=1:no_subjects
%     
%     subj_states=states(strcmp(subjects,subj_labels{i}));
%     no_epochs=length(subj_states);
%     t=[1:no_epochs]*seconds_per_epoch/(60*60);
%     
%     subj_MI_measures=zeros(no_epochs,3);
%     
%     [subj_MI_measures(:,1),subj_MI_max_index]=max(MI(strcmp(subjects,subj_labels{i}),:),[],2);
%     subj_MI_measures(:,2)=bands_lo(ceil(subj_MI_max_index/no_amps));
%     subj_MI_measures(:,3)=bands_hi(mod(subj_MI_max_index,no_amps)+1);
%     
%     for m=1:no_measures
%         
%         figure()
%         
%         for s=1:no_states
%             
%             state_flag=ordered_state_flags(s);
%             
%             state_indices=find(subj_states==state_flag);
%             
%             plot(t(state_indices),subj_MI_measures(state_indices,m),state_markers{state_flag+1},'MarkerSize',state_sizes(state_flag+1))
%             
%             hold on
%             
%         end
%    
%         legend(state_labels{ordered_state_flags+1})
%         title([measure_titles{m},' for ',subj_labels{i}])
%         xlabel('Time (hours)')
%         ylabel(measure_titles{m})
%         saveas(gcf,[filename(1:end-4),'_',subj_labels{i},'_',measure_labels{m},'.fig'])
%         
%     end
%     
% end

for a=1:no_als

    amp_indices=bands_hi>=amp_lims(a,1) & bands_hi<=amp_lims(a,2);
    amp_indices=repmat(amp_indices',1,no_phases);
    
    phase_indices=bands_lo>=phase_lims(a,1) & bands_lo<=phase_lims(a,2);
    phase_indices=repmat(phase_indices,no_amps,1);
    
    sum_indices=reshape(amp_indices & phase_indices,1,no_amps*no_phases);
    
    freq_labels{a}=[num2str(amp_lims(a,1)),'to',num2str(amp_lims(a,2)),'by',num2str(phase_lims(a,1)),'to',num2str(phase_lims(a,2))];
    freq_labels_long{a}=[num2str(amp_lims(a,1)),' to ',num2str(amp_lims(a,2)),' Hz Amplitude by ',num2str(phase_lims(a,1)),' to ',num2str(phase_lims(a,2)),' Hz Phase'];
    
    MI_sum(:,a)=sum(MI(:,sum_indices==1),2);
    
    figure()
    
    boxplot(MI_sum(:,a),states,'labels',state_labels)
    title({'Summed IE';char(freq_labels_long{a})})
    ylabel('Summed IE')
    saveas(gcf,[filename(1:end-4),'_',freq_labels{a},'.fig'])
   
    for i=1:no_subjects
        
        subj_states=states(strcmp(subjects,subj_labels{i}));
        
        subj_MI_sum=MI_sum(strcmp(subjects,subj_labels{i}),a);
                
        no_epochs=length(subj_states);
        
        t=[1:no_epochs]*seconds_per_epoch/(60*60);
        
        figure()
        
        for s=1:no_states
                        
            state_indices=find(states==s-1);
            
            mean_MI_sum(s,a)=mean(MI_sum(state_indices,a));
            
            std_MI_sum(s,a)=std(MI_sum(state_indices,a))/sqrt(length(state_indices));
            
            state_flag=ordered_state_flags(s);
            
            subj_state_indices=find(subj_states==state_flag);
            
            plot(t(subj_state_indices),subj_MI_sum(subj_state_indices),state_markers{state_flag+1},'MarkerSize',state_sizes(state_flag+1))
            
            hold on
            
        end
        
        legend(state_labels{ordered_state_flags+1})
        title({['Summed MI for ',subj_labels{i}];freq_labels_long{a}})
        xlabel('Time (hours)')
        ylabel('Summed MI')
        saveas(gcf,[filename(1:end-4),'_',subj_labels{i},'_',freq_labels{a},'.fig'])
        
    end

end

figure()

h=barwitherr(std_MI_sum,mean_MI_sum);
legend(h,freq_labels_long)
title('Summed IE by State')
set(gca,'XTickLabel',state_labels)
colormap hot
saveas(gcf,[filename(1:end-4),'_barplot.fig'])

al_pairs=nchoosek(1:no_als,2);

for p=1:length(al_pairs)
    
    figure()
    
    for s=1:no_states
        
        state_flag=ordered_state_flags(s);
        
        state_indices=find(states==state_flag);
        
        plot(MI_sum(state_indices,al_pairs(p,1)),MI_sum(state_indices,al_pairs(p,2)),state_markers{state_flag+1},'MarkerSize',state_sizes(state_flag+1))
        
        hold on
        
    end

    legend(state_labels{ordered_state_flags+1})
    xlabel({'Summed MI';freq_labels_long{al_pairs(p,1)}})
    ylabel({'Summed MI';freq_labels_long{al_pairs(p,2)}})
    saveas(gcf,[filename(1:end-4),'_',freq_labels{al_pairs(p,1)},'_',freq_labels{al_pairs(p,2)},'.fig'])
    
end

