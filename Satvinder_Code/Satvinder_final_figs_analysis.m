function [corr_vec,max_corr_vec]=Satvinder_final_figs_analysis(matrix_rows,matrix_columns,x_ticks,y_ticks,no_reps)

[filename,filepath]=uigetfile('*txt','Choose file containing collected measure (e.g., MI or AVP).');
[statename,statepath]=uigetfile('*states.txt','Choose file containing states.');
[subjname,subjpath]=uigetfile('*subjects.txt','Choose file containing subjects.');

MI=load([filepath,filename]);
% [rows,cols]=size(MI);
states=load([statepath,statename]);
subjects=textread([subjpath,subjname],'%s');

state_labels={'Wake','NREM','REM','DREADD'};
no_states=length(state_labels);
state_indices=[0 2];

subj_labels={'sk47','sk48','sk49','sk50','sk51','sk52'};
no_subjects=length(subj_labels);

median_MI=zeros(matrix_rows,matrix_columns,4);
mean_MI=zeros(matrix_rows,matrix_columns,4);
std_MI=zeros(matrix_rows,matrix_columns,4);

% %%%%%%%%%%%%%%%%%%% MEDIAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figs=[];
% 
% for i=1:no_states, 
%     
%     MI_temp=reshape(median(MI(states==i-1,:)),matrix_rows,matrix_columns); 
%     
%     figure(), imagesc(MI_temp)
%     
%     figs(i)=gcf;
%     
%     handl=figure_replotter(figs(i),1,1,x_ticks,y_ticks,{['Median ',state_labels{i}]});
%     
%     saveas(handl,[filename(1:end-4),'_',state_labels{i},'_median.fig']);
%     
%     median_MI(:,:,i)=MI_temp; 
% 
% end
% 
% figure_replotter(figs,1,4,x_ticks,y_ticks,state_labels);
% 
% saveas(gcf,[filename(1:end-4),'_median.fig']);
% 
% %%%%%%%%%%%%%%%%%%%%% MEAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figs=[];
% 
% for i=1:no_states, 
%     
%     MI_temp=reshape(mean(MI(states==i-1,:)),matrix_rows,matrix_columns); 
%     
%     figure(), imagesc(MI_temp)
%     
%     figs(i)=gcf;
%     
%     handl=figure_replotter(figs(i),1,1,x_ticks,y_ticks,{['Mean ',state_labels{i}]});
%     
%     saveas(handl,[filename(1:end-4),'_',state_labels{i},'_mean.fig']);
%     
%     mean_MI(:,:,i)=MI_temp; 
% 
% end
% 
% figure_replotter(figs,1,4,x_ticks,y_ticks,state_labels);
% 
% saveas(gcf,[filename(1:end-4),'_mean.fig']);
% 
% %%%%%%%%%%%%%%%%%%%%%% STD FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figs=[];
% 
% for i=1:no_states, 
%     
%     MI_temp=reshape(std(MI(states==i-1,:)),matrix_rows,matrix_columns); 
%     
%     figure(), imagesc(MI_temp)
%     
%     figs(i)=gcf;
%     
%     handl=figure_replotter(figs(i),1,1,x_ticks,y_ticks,{['Standard Deviation ',state_labels{i}]});
%     
%     saveas(handl,[filename(1:end-4),'_',state_labels{i},'_std.fig']);
%     
%     std_MI(:,:,i)=MI_temp; 
% 
% end
% 
% figure_replotter(figs,1,4,x_ticks,y_ticks,state_labels);
% 
% saveas(gcf,[filename(1:end-4),'_std.fig']);
% 
% %%%%%%%%%%%%%%%%%%% RANKSUM FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figs=[];
% 
% p=zeros(2,matrix_rows*matrix_columns);
% h=zeros(2,matrix_rows*matrix_columns);
% z=zeros(2,matrix_rows*matrix_columns);
% 
% for i=1:2, 
%     
%     for j=1:matrix_rows*matrix_columns
%         
%         [p(i,j),h(i,j),stats]=ranksum(MI(states==state_indices(i),j),MI(states==3,j),'alpha',0.01/matrix_rows*matrix_columns);
%     
%         z(i,j)=stats.zval;
%         
%     end
% 
%     temp_MI=reshape(z(i,:),matrix_rows,matrix_columns);
%     
%     figure(), imagesc(temp_MI)
%     
%     figs(i)=gcf;
%     
%     handl=figure_replotter(gcf,1,1,x_ticks,y_ticks,{[state_labels{state_indices(i)+1},' Ranksum z-Value by DREADD']});
%     
%     saveas(handl,[filename(1:end-4),'_',state_labels{state_indices(i)+1},'_ranksum_zval_vs_DREADD.fig']);
%     
% end
% 
% figure_replotter(figs,1,2,x_ticks,y_ticks,{'Wake vs. DREADD, Ranksum z-Value','REM vs. DREADD, Ranksum z-Value'});
% 
% saveas(gcf,[filename(1:end-4),'_WR_ranksum_zval_by_D.fig']);
% 
% % SIGNIFICANT RANKSUM Z-VALUES.
% 
% figs=[];
% 
% z_sig=z;
% z_sig(h==0)=nan;
% 
% for i=1:2
%     
%     figure(), colorplot(reshape(z_sig(i,:),matrix_rows,matrix_columns))
%     
%     figs(i)=gcf;
%     
%     handl=figure_replotter(gcf,1,1,x_ticks,y_ticks,{{[state_labels{state_indices(i)+1},' vs. DREADD'];'Significant Ranksum z-Value'}});
%     
%     saveas(gcf,[filename(1:end-4),'_',state_labels{state_indices(i)+1},'_ranksum_zval_vs_DREADD.fig']);
%     
% end
% 
% handl=figure_replotter(figs,1,2,x_ticks,y_ticks,{'Wake vs. DREADD, Significant Ranksum z-Value','REM vs. DREADD, Significant Ranksum z-Value'});
% 
% saveas(gcf,[filename(1:end-4),'_WR_ranksum_sig_zval_by_D.fig']);
% 
% %%%%%%%%%%%%%%%%%%% Z-VALUE BY DREADD FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figs=[];
% 
% mean_MI_zs=zeros(matrix_rows,matrix_columns,2);
% 
% for i=1:2
%      
%     MI_zs=zeros(length(states==state_indices(i)),matrix_rows*matrix_columns);
%     
%     MI_zs_index=0;
%     
%     for s=1:no_subjects
%         
%         subject=subj_labels{s};
%         
%         state_epochs=find(strcmp(subjects,subject)==1 & states==state_indices(i));
%         no_state_epochs=length(state_epochs);
%         
%         DREADD_epochs=find(strcmp(subjects,subject)==1 & states==3);
%         DREADD_mean=mean(MI(DREADD_epochs,:));
%         DREADD_std=std(MI(DREADD_epochs,:));
%         DREADD_mean_mat=repmat(DREADD_mean,no_state_epochs,1);
%         
%         MI_zs([1:no_state_epochs]+MI_zs_index,:)=(MI(state_epochs,:)-DREADD_mean_mat)*diag(1./DREADD_std);
%         
%         MI_zs_index=MI_zs_index+no_state_epochs;
%         
%     end
%     
%     temp_MI=reshape(mean(MI_zs),matrix_rows,matrix_columns);
%         
%     figure(), imagesc(temp_MI)
%     
%     figs(i)=gcf;
%     
%     handl=figure_replotter(gcf,1,1,x_ticks,y_ticks,{['Mean ',state_labels{state_indices(i)+1},' z-Score by DREADD']});
%     
%     saveas(handl,[filename(1:end-4),'_',state_labels{state_indices(i)+1},'_zs_by_DREADD.fig']);
%     
%     mean_MI_zs(:,:,i)=temp_MI;
%     
% end
%     
% figure_replotter(figs,1,2,x_ticks,y_ticks,{'Mean Wake z-Score by DREADD','Mean REM z-Score by DREADD'});
% 
% saveas(gcf,[filename(1:end-4),'_WR_zs_by_D.fig']);
    
%%%%%%%%%%%%%%%%%%% 2D CORRELATION ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

corr_vec=zeros(no_reps*no_subjects,2);
max_corr_vec=zeros(no_reps*no_subjects,2);

for i=1:2
    
    for s=1:no_subjects
        
        corr_index=(s-1)*no_reps;
        
        subject=subj_labels{s};
        
        state_epochs=find(strcmp(subjects,subject)==1 & states==state_indices(i));
        DREADD_epochs=find(strcmp(subjects,subject)==1 & states==3);
        
        state_choices=randi(length(state_epochs),1,no_reps);
        DREADD_choices=randi(length(DREADD_epochs),1,no_reps);
        
        parfor j=1:no_reps
            
            DREADD_MI=MI(DREADD_epochs(DREADD_choices(j)),:);
            state_MI=MI(state_epochs(state_choices(j)),:);
            corr_vec(corr_index+j,i)=corr(DREADD_MI',state_MI');
                        
            DREADD_MI=(DREADD_MI-mean(DREADD_MI))/std(DREADD_MI);
            DREADD_MI=reshape(DREADD_MI,matrix_rows,matrix_columns);
            
            state_MI=(state_MI-mean(state_MI))/std(state_MI);
            state_MI=reshape(state_MI,matrix_rows,matrix_columns);
            
            max_corr_vec(corr_index+j,i)=max(max(xcorr2(DREADD_MI,state_MI)));
            
        end
        
    end
    
end

save([filename(1:end-4),'_corr_',num2str(no_reps),'.mat'],'corr_vec','max_corr_vec')

corr_labels={'corr','max_corr'};

corr_vec(:,3:4)=max_corr_vec;

for i=1:2
    
    corr_temp=corr_vec(:,state_indices(i)+1:state_indices(i)+2);
    
    p_corr=ranksum(corr_temp(:,1),corr_temp(:,2),'alpha',0.01);
    
    figure(), boxplot(corr_temp,{'Wake','REM'},'notch','on')
    
    title(['P-Value p=',num2str(p_corr,'%0.5g')])
    
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_boxplot.fig'])
    
    min_corr=min(min(corr_temp));
    max_corr=max(max(corr_temp));
    
    corr_bin_centers=linspace(min_corr,max_corr,100);
%     corr_bin_centers=logspace(log10(min_corr),log10(max_corr),100);

    h_w=hist(corr_temp(:,1),corr_bin_centers);
    h_r=hist(corr_temp(:,2),corr_bin_centers);
    
    figure(), plot(corr_bin_centers',[h_w' h_r']/no_reps)
    legend({'Wake','REM'})
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_hist.fig'])
    
    corr_sort=sort(corr_temp);
    
    figure(), plot(corr_sort,repmat([1:length(corr_sort)]',1,2)/length(corr_sort))
    legend({'Wake','REM'})
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_cdf.fig'])
    
    [~,p_dist]=kstest2(corr_temp(:,1),corr_temp(:,2),0.01,'larger');
    
    figure(), plot(corr_sort(:,2),corr_sort(:,1))
    hold on
    plot(corr_sort(:,2),corr_sort(:,2),'k')
    title(['P-Value p=',num2str(p_dist,'%0.5g')])
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_ks.fig'])
    
end

end