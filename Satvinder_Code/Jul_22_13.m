corr_vec(:,3:4)=max_corr_vec;

for i=1:2
    
    corr_temp=corr_vec(:,state_indices(i)+1:state_indices(i)+2);

    p_corr=ranksum(corr_temp(:,1),corr_temp(:,2),'alpha',0.01);

    figure(), boxplot(corr_temp,{'Wake','REM'},'notch','on')
  
    title(['P-Value p=',num2str(p_corr)])

    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_boxplot.fig'])

    min_corr=min(min(corr_temp));
    max_corr=max(max(corr_temp));
    
    corr_bin_centers=linspace(min_corr,max_corr,100);
    
    h_w=hist(corr_temp(:,1),corr_bin_centers);
    h_r=hist(corr_temp(:,2),corr_bin_centers);

    figure(), loglog(corr_bin_centers',[h_w' h_r']/no_reps)
    legend({'Wake','REM'})
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_hist.fig'])
    
    figure(), loglog(sort(corr_temp),repmat([1:no_reps]',1,2)/no_reps)
    legend({'Wake','REM'})
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_cdf.fig'])

    corr_sort=sort(corr_temp);
    [h,p_dist]=kstest2(corr_temp(:,1),corr_temp(:,2),0.01,'larger');
    
    figure(), plot(corr_sort(:,2),corr_sort(:,1))
    hold on
    plot(corr_sort(:,2),corr_sort(:,2),'k')
    title(['P-Value p=',num2str(p_dist)])
    saveas(gcf,[filename(1:end-4),'_',corr_labels{i},'_ks.fig'])

end