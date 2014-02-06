function [corr_vec,max_corr_vec]=Satvinder_final_figs_analysis_MI(no_reps)

matrix_rows=33; matrix_columns=33;
x_ticks=4:.25:12; y_ticks=20:5:180;

[filename,filepath]=uigetfile('*MI.txt','Choose file containing collected MI.');
[statename,statepath]=uigetfile('*states.txt','Choose file containing states.');
[subjname,subjpath]=uigetfile('*subjects.txt','Choose file containing subjects.');

% MI=load([filepath,filename]);
% % [rows,cols]=size(MI);
% states=load([statepath,statename]);
% subjects=textread([subjpath,subjname],'%s');

state_labels={'Wake','NREM','REM','DREADD'};
short_state_labels={'W','N','R','D'};
no_states=length(state_labels);
state_indices=[2 0 3];
state_pairs=nchoosek(state_indices,2);
no_pairs=length(state_pairs);

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
% p=zeros(3,matrix_rows*matrix_columns);
% h=zeros(3,matrix_rows*matrix_columns);
% z=zeros(3,matrix_rows*matrix_columns);
% 
% for i=1:no_pairs, 
%     
%     for j=1:matrix_rows*matrix_columns
%         
%         [p(i,j),h(i,j),stats]=ranksum(MI(states==state_pairs(i,1),j),MI(states==state_pairs(i,2),j),'alpha',0.01/matrix_rows*matrix_columns);
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
%     handl=figure_replotter(gcf,1,1,x_ticks,y_ticks,{[state_labels{state_pairs(i,1)+1},' Ranksum z-Value by ',state_labels{state_pairs(i,2)+1}]});
%         
%     saveas(handl,[filename(1:end-4),'_',state_labels{state_pairs(i,1)+1},'_ranksum_zval_vs_',state_labels{state_pairs(i,2)+1},'.fig']);
%     
%     ranksum_titles{i}=[state_labels{state_pairs(i,1)+1},' vs. ',state_labels{state_pairs(i,2)+1},', Ranksum z-Value'];
%     
% end
% 
% figure_replotter(figs,1,3,x_ticks,y_ticks,ranksum_titles);
% 
% saveas(gcf,[filename(1:end-4),'_WRD_ranksum_zval.fig']);
% 
% % SIGNIFICANT RANKSUM Z-VALUES.
% 
% figs=[];
% 
% z_sig=z;
% z_sig(h==0)=nan;
% 
% for i=1:no_pairs
%     
%     figure(), colorplot(reshape(z_sig(i,:),matrix_rows,matrix_columns))
%     
%     figs(i)=gcf;
%     
%     handl=figure_replotter(gcf,1,1,x_ticks,y_ticks,{{[state_labels{state_pairs(i,1)+1},' vs. ',state_labels{state_pairs(i,2)+1}];'Significant Ranksum z-Value'}});
%     
%     saveas(gcf,[filename(1:end-4),'_',state_labels{state_pairs(i,1)+1},'_ranksum_zval_vs_',state_labels{state_pairs(i,2)+1},'.fig']);
%         
%     sig_ranksum_titles{i}=[state_labels{state_pairs(i,1)+1},' vs. ',state_labels{state_pairs(i,2)+1},', Significant Ranksum z-Value'];
%     
% end
% 
% handl=figure_replotter(figs,1,no_pairs,x_ticks,y_ticks,sig_ranksum_titles);
% 
% saveas(gcf,[filename(1:end-4),'_WRD_ranksum_sig_zval.fig']);
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
%     zs_legend{i}=[state_labels{state_indices(i)+1},' z-Score by DREADD'];
%     
%     handl=figure_replotter(gcf,1,1,x_ticks,y_ticks,{['Mean ',zs_legend{i}]});
%         
%     saveas(handl,[filename(1:end-4),'_',state_labels{state_indices(i)+1},'_zs_by_DREADD.fig']);
%     
%     mean_MI_zs(:,:,i)=temp_MI;
%     
% end
%     
% figure_replotter(figs,1,2,x_ticks,y_ticks,zs_legend);
% 
% saveas(gcf,[filename(1:end-4),'_WR_zs_by_D.fig']);
    
%%%%%%%%%%%%%%%%%%% 2D CORRELATION ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

corr_vec=zeros(no_reps*no_subjects,3);
max_corr_vec=zeros(no_reps*no_subjects,3);

for i=1:no_pairs
    
%     pair_labels=[state_labels(state_pairs(i,1)+1),' vs. ',state_labels(state_pairs(i,1)+1)];
    pair_labels{i}=[char(short_state_labels(state_pairs(i,1)+1)),char(short_state_labels(state_pairs(i,2)+1))];
    
%     for s=1:no_subjects
%         
%         corr_index=(s-1)*no_reps;
%         
%         subject=subj_labels{s};
%         
%         state1_epochs=find(strcmp(subjects,subject)==1 & states==state_pairs(i,1));
%         state2_epochs=find(strcmp(subjects,subject)==1 & states==state_pairs(i,2));
%         
%         state1_choices=randi(length(state1_epochs),1,no_reps);
%         state2_choices=randi(length(state2_epochs),1,no_reps);
%         
%         parfor j=1:no_reps
%             
%             state2_MI=MI(state2_epochs(state2_choices(j)),:);
%             state1_MI=MI(state1_epochs(state1_choices(j)),:);
%             corr_vec(corr_index+j,i)=corr(state2_MI',state1_MI');
%                         
%             state2_MI=(state2_MI-mean(state2_MI))/std(state2_MI);
%             state2_MI=reshape(state2_MI,matrix_rows,matrix_columns);
%             
%             state1_MI=(state1_MI-mean(state1_MI))/std(state1_MI);
%             state1_MI=reshape(state1_MI,matrix_rows,matrix_columns);
%             
%             max_corr_vec(corr_index+j,i)=max(max(xcorr2(state2_MI,state1_MI)));
%             
%         end
%         
%     end
    
end

% save([filename(1:end-4),'_corr_',num2str(no_reps),'.mat'],'corr_vec','max_corr_vec')
load([filename(1:end-4),'_corr_',num2str(no_reps),'.mat'],'corr_vec','max_corr_vec')

corr_labels={'corr','max_corr'};

corr_vec(:,(no_pairs+1):2*no_pairs)=max_corr_vec;

for i=1:2
    
    corr_temp=corr_vec(:,(i-1)*no_pairs+[1:no_pairs]);
    
    corr_pairs=nchoosek([1 2 3],2);
    
    title_string=['p-Values: '];
    
    for j=1:no_pairs

        [p_corr(j),~]=ranksum(corr_temp(:,corr_pairs(j,1)),corr_temp(:,corr_pairs(j,2)),'alpha',0.01);
          
        corr_legend{j}=[char(state_labels(state_pairs(j,1)+1)),' vs. ',char(state_labels(state_pairs(j,2)+1))];
        
        ranksum_legend{j}=[char(pair_labels(corr_pairs(j,1))),' vs. ',char(pair_labels(corr_pairs(j,2)))];
        
        title_string=[title_string,ranksum_legend{j},' = ',num2str(p_corr(j)),'; '];
        
    end
        
    figure(), boxplot(corr_temp,corr_legend,'notch','on')
    
    title({[num2str(no_reps*no_subjects),' Random Correlations'];title_string})
    ylabel('Correlation')
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_boxplot.fig'])
    
    min_corr=min(min(corr_temp));
    max_corr=max(max(corr_temp));
    
    corr_bin_centers=linspace(min_corr,max_corr,100);
%     corr_bin_centers=logspace(log10(min_corr),log10(max_corr),100);

    h_wr=hist(corr_temp(:,1),corr_bin_centers);
    h_wd=hist(corr_temp(:,2),corr_bin_centers);
    h_rd=hist(corr_temp(:,3),corr_bin_centers);
    
    figure(), plot(corr_bin_centers',[h_wr' h_wd' h_rd']/no_reps)
    legend(corr_legend)
    title('Distribution of Random Correlations')
    xlabel('Correlation Value')
    ylabel('Proportion Observed')
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_pdf.fig'])
    
    corr_sort=sort(corr_temp);
    
    figure(), plot(corr_sort,repmat([1:length(corr_sort)]',1,no_pairs)/length(corr_sort))
    legend(corr_legend)
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_cdf.fig'])
    
%     [~,p_dist]=kstest2(corr_temp(:,1),corr_temp(:,2),0.01,'larger');
%     
%     figure(), plot(corr_sort(:,2),corr_sort(:,1))
%     hold on
%     plot(corr_sort(:,2),corr_sort(:,2),'k')
%     title(['P-Value p=',num2str(p_dist)])
%     saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_ks.fig'])
    
end