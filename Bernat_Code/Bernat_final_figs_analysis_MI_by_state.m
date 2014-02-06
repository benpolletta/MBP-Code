function Bernat_final_figs_analysis_MI_by_state

x_ticks=1:.25:12; y_ticks=20:5:200;
matrix_rows=length(y_ticks); matrix_columns=length(x_ticks);

[filename,filepath]=uigetfile('*by_state_MI.txt','Choose file containing collected MI.');
[periodname,periodpath]=uigetfile('*by_state_periods.txt','Choose file containing periods.');
[statename,statepath]=uigetfile('*by_state_states.txt','Choose file containing states.');
[subjname,subjpath]=uigetfile('*by_state_subjects.txt','Choose file containing subjects.');

MI=load([filepath,filename]);
% [rows,cols]=size(MI);
periods=textread([periodpath,periodname],'%s');
states=textread([statepath,statename],'%s');
subjects=textread([subjpath,subjname],'%s');

p=1;
for i=1:1
    period_labels{p}=['Hours ',num2str(4*i),' to ',num2str(4*(i-1)+1),' Preinjection'];
    short_period_labels{p}=['pre',num2str(4*i),'to',num2str(4*(i-1)+1)];
    p=p+1;
end
for i=1:4
    period_labels{p}=['Hours ',num2str(4*(i-1)+1),' to ',num2str(4*i),' Postinjection'];
    short_period_labels{p}=['post',num2str(4*(i-1)+1),'to',num2str(4*i)];
    p=p+1;
end
no_periods=length(period_labels);

long_state_labels={'Wake','NREM','REM'};
state_labels={'W','NR','R'};
no_states=length(state_labels);

subj_labels={'A99','A102','A103','A104','A105','A106'};
no_subjects=length(subj_labels);

fig_dir=filename(1:end-7);
mkdir (fig_dir)

%%%%%%%%%%%%%%%%%%% MEDIAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all')

figs=[];

for s=1:no_states
    
    state=char(state_labels{s});
    
    MI_state=MI(strcmp(states,state)==1,:);
    
    periods_state=periods(strcmp(states,state)==1);
    
    for p=1:no_periods
        
        short_period_label=char(short_period_labels{p});
        
        MI_temp=MI_state(strcmp(periods_state,short_period_label)==1,:);
        
        if ~isempty(MI_temp) && size(MI_temp,1)>=5
            
            MI_temp=reshape(nanmedian(MI_temp),matrix_rows,matrix_columns);
            
        else
            
            MI_temp=nan(matrix_rows,matrix_columns);
            
        end
                
        figure(), imagesc(MI_temp)
        
        figs((s-1)*no_periods+p)=gcf;
        
        handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,{['Median ',period_labels{p},' ',long_state_labels{s}]});
        
        saveas(handl,[fig_dir,'/',filename(1:end-4),'_',state,'_',short_period_label,'_median.fig']);
        
    end
    
end

figure_replotter(figs,no_states,no_periods,x_ticks,y_ticks,{period_labels{:}, state_labels{:}});

saveas(gcf,[fig_dir,'/',filename(1:end-4),'_median.fig']);
saveas(gcf,[fig_dir,'/',filename(1:end-4),'_median.pdf']);

%%%%%%%%%%%%%%%%%%%%% MEAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all')

figs=[];

for s=1:no_states
    
    state=char(state_labels{s});
    
    MI_state=MI(strcmp(states,state)==1,:);
    
    periods_state=periods(strcmp(states,state)==1);
    
    for p=1:no_periods
        
        short_period_label=char(short_period_labels{p});
        
        MI_temp=MI_state(strcmp(periods_state,short_period_label)==1,:);
        
        if ~isempty(MI_temp) && size(MI_temp,1)>=5
            
            MI_temp=reshape(nanmean(MI_temp),matrix_rows,matrix_columns);
            
        else
            
            MI_temp=nan(matrix_rows,matrix_columns);
            
        end
                
        figure(), imagesc(MI_temp)
        
        figs((s-1)*no_periods+p)=gcf;
        
        handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,{['Mean ',period_labels{p},' ',long_state_labels{s}]});
        
        saveas(handl,[fig_dir,'/',filename(1:end-4),'_',state,'_',short_period_label,'_mean.fig']);
        
    end
    
end

figure_replotter(figs,no_states,no_periods,x_ticks,y_ticks,{period_labels{:}, state_labels{:}});

saveas(gcf,[fig_dir,'/',filename(1:end-4),'_mean.fig']);
saveas(gcf,[fig_dir,'/',filename(1:end-4),'_mean.pdf']);

%%%%%%%%%%%%%%%%%%%%%% STD FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all')

figs=[];

for s=1:no_states
    
    state=char(state_labels{s});
    
    MI_state=MI(strcmp(states,state)==1,:);
    
    periods_state=periods(strcmp(states,state)==1);
    
    for p=1:no_periods
        
        short_period_label=char(short_period_labels{p});
        
        MI_temp=MI_state(strcmp(periods_state,short_period_label)==1,:);
        
        if ~isempty(MI_temp) && size(MI_temp,1)>=5
            
            MI_temp=reshape(nanstd(MI_temp),matrix_rows,matrix_columns);
            
        else
            
            MI_temp=nan(matrix_rows,matrix_columns);
            
        end
                
        figure(), imagesc(MI_temp)
        
        figs((s-1)*no_periods+p)=gcf;
        
        handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,{['St. Dev. ',period_labels{p},' ',long_state_labels{s}]});
        
        saveas(handl,[fig_dir,'/',filename(1:end-4),'_',state,'_',short_period_label,'_std.fig']);
        
    end
    
end

figure_replotter(figs,no_states,no_periods,x_ticks,y_ticks,{period_labels{:}, state_labels{:}});

saveas(gcf,[fig_dir,'/',filename(1:end-4),'_std.fig']);
saveas(gcf,[fig_dir,'/',filename(1:end-4),'_std.pdf']);

%%%%%%%%%%%%%%%%%%%%% FIGURES BY SUBJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s=1:no_subjects
    
    subject=char(subj_labels{s});
    
    subj_MI=MI(strcmp(subjects,subject)==1,:);
    
    subj_states=states(strcmp(subjects,subject)==1,:);
    
    subj_periods=periods(strcmp(subjects,subject)==1,:);
    
%%%%%%%%%%%%%%%%%%% MEDIAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    close('all')
    
    figs=[];
    
    for s=1:no_states
        
        state=char(state_labels{s});
        
        MI_state=subj_MI(strcmp(subj_states,state)==1,:);
        
        periods_state=subj_periods(strcmp(subj_states,state)==1);
        
        for p=1:no_periods
            
            short_period_label=char(short_period_labels{p});
            
            MI_temp=MI_state(strcmp(periods_state,short_period_label)==1,:);
            
            if ~isempty(MI_temp) && size(MI_temp,1)>=5
                
                MI_temp=reshape(nanmedian(MI_temp),matrix_rows,matrix_columns);
                
            else
                
                MI_temp=nan(matrix_rows,matrix_columns);
                
            end
            
            figure(), imagesc(MI_temp)
            
            figs((s-1)*no_periods+p)=gcf;
            
            handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,{[subject,' Median ',period_labels{p},' ',long_state_labels{s}]});
            
            saveas(handl,[fig_dir,'/',filename(1:end-4),'_',state,'_',short_period_label,'_',subject,'_median.fig']);
            
        end
        
    end
    
    figure_replotter(figs,no_states,no_periods,x_ticks,y_ticks,{period_labels{:}, state_labels{:}});
    
    saveas(gcf,[fig_dir,'/',filename(1:end-4),'_',subject,'_median.fig']);
    saveas(gcf,[fig_dir,'/',filename(1:end-4),'_',subject,'_median.pdf']);
    
%%%%%%%%%%%%%%%%%%%%% MEAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    close('all')
    
    figs=[];
    
    for s=1:no_states
        
        state=char(state_labels{s});
        
        MI_state=subj_MI(strcmp(subj_states,state)==1,:);
        
        periods_state=subj_periods(strcmp(subj_states,state)==1);
        
        for p=1:no_periods
            
            short_period_label=char(short_period_labels{p});
            
            MI_temp=MI_state(strcmp(periods_state,short_period_label)==1,:);
            
            if ~isempty(MI_temp) && size(MI_temp,1)>=5
                
                MI_temp=reshape(nanmean(MI_temp),matrix_rows,matrix_columns);
                
            else
                
                MI_temp=nan(matrix_rows,matrix_columns);
                
            end
            
            figure(), imagesc(MI_temp)
            
            figs((s-1)*no_periods+p)=gcf;
            
            handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,{[subject,' Mean ',period_labels{p},' ',long_state_labels{s}]});
            
            saveas(handl,[fig_dir,'/',filename(1:end-4),'_',state,'_',short_period_label,'_',subject,'_mean.fig']);
            
        end
        
    end
    
    figure_replotter(figs,no_states,no_periods,x_ticks,y_ticks,{period_labels{:}, state_labels{:}});
    
    saveas(gcf,[fig_dir,'/',filename(1:end-4),'_',subject,'_mean.fig']);
    saveas(gcf,[fig_dir,'/',filename(1:end-4),'_',subject,'_mean.pdf']);
    
%%%%%%%%%%%%%%%%%%%%%% STD FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    close('all')
    
    figs=[];
    
    for s=1:no_states
        
        state=char(state_labels{s});
        
        MI_state=subj_MI(strcmp(subj_states,state)==1,:);
        
        periods_state=subj_periods(strcmp(subj_states,state)==1);
        
        for p=1:no_periods
            
            short_period_label=char(short_period_labels{p});
            
            MI_temp=MI_state(strcmp(periods_state,short_period_label)==1,:);
            
            if ~isempty(MI_temp) && size(MI_temp,1)>=5
                
                MI_temp=reshape(nanstd(MI_temp),matrix_rows,matrix_columns);
                
            else
                
                MI_temp=nan(matrix_rows,matrix_columns);
                
            end
            
            figure(), imagesc(MI_temp)
            
            figs((s-1)*no_periods+p)=gcf;
            
            handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,{[subject,' St. Dev. ',period_labels{p},' ',long_state_labels{s}]});
            
            saveas(handl,[fig_dir,'/',filename(1:end-4),'_',state,'_',short_period_label,'_',subject,'_std.fig']);
            
        end
        
    end
    
    figure_replotter(figs,no_states,no_periods,x_ticks,y_ticks,{period_labels{:}, state_labels{:}});
    
    saveas(gcf,[fig_dir,'/',filename(1:end-4),'_',subject,'_std.fig']);
    saveas(gcf,[fig_dir,'/',filename(1:end-4),'_',subject,'_std.pdf']);
    
end