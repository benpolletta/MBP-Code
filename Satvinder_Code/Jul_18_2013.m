[filename,filepath]=uigetfile('*MI.txt','Choose file containing collected MI.');
[statename,statepath]=uigetfile('*states.txt','Choose file containing states.');

MI=load([filepath,filename]);
[rows,cols]=size(MI);
states=load([statepath,statename]);

state_labels={'Wake','NREM','REM','DREADD'};

median_MI=zeros(33,33,4);
mean_MI=zeros(33,33,4);
std_MI=zeros(33,33,4);

figs=[];

for i=1:4, 
    
    MI_temp=reshape(median(MI(states==i-1,:)),33,33); 
    
    figure(), imagesc(MI_temp)
    
    figs(i)=gcf;
    
    figure_replotter(figs(i),1,1,4:.25:12,20:5:180,{['Median ',state_labels{i}]})
    
    saveas(gcf,[filename(1:end-4),'_',state_labels{i},'_median.fig']);
    
    median_MI(:,:,i)=MI_temp; 

end

figure_replotter(figs,1,4,4:.25:12,20:5:180,state_labels);

saveas(gcf,[filename(1:end-4),'_median.fig']);

figs=[];

for i=1:4, 
    
    MI_temp=reshape(mean(MI(states==i-1,:)),33,33); 
    
    figure(), imagesc(MI_temp)
    
    figs(i)=gcf;
    
    figure_replotter(figs(i),1,1,4:.25:12,20:5:180,{['Mean ',state_labels{i}]})
    
    saveas(gcf,[filename(1:end-4),'_',state_labels{i},'_mean.fig']);
    
    mean_MI(:,:,i)=MI_temp; 

end

figure_replotter(figs,1,4,4:.25:12,20:5:180,state_labels);

saveas(gcf,[filename(1:end-4),'_mean.fig']);

figs=[];

for i=1:4, 
    
    MI_temp=reshape(std(MI(states==i-1,:)),33,33); 
    
    figure(), imagesc(MI_temp)
    
    figs(i)=gcf;
    
    figure_replotter(figs(i),1,1,4:.25:12,20:5:180,{['Standard Deviation ',state_labels{i}]})
    
    saveas(gcf,[filename(1:end-4),'_',state_labels{i},'_std.fig']);
    
    std_MI(:,:,i)=MI_temp; 

end

figure_replotter(figs,1,4,4:.25:12,20:5:180,state_labels);

saveas(gcf,[filename(1:end-4),'_std.fig']);

state_indices=[0 2];

figs=[];

mean_MI_zs=zeros(33,33,2);

for i=1:2, 
    
    DREADD_mean=reshape(mean_MI(:,:,4),1,1089); 
    DREADD_std=reshape(std_MI(:,:,4),1,1089); 

    DREADD_mean_mat=repmat(DREADD_mean,length(find(states==state_indices(i))),1);
        
    MI_zs=(MI(states==state_indices(i),:)-DREADD_mean_mat)*diag(1./DREADD_std);    
    
    temp_MI=reshape(mean(MI_zs),33,33);
    
    figure(), imagesc(temp_MI)
    
    figs(i)=gcf;
    
    figure_replotter(gcf,1,1,4:.25:12,20:5:180,{['Mean ',state_labels{state_indices(i)+1},' z-Score by DREADD']})
    
    saveas(gcf,[filename(1:end-4),'_',state_labels{state_indices(i)+1},'_zs_by_DREADD.fig']);
    
    mean_MI_zs(:,:,i)=temp_MI;
    
end

figure_replotter(figs,1,2,4:.25:12,20:5:180,{'Mean Wake z-Score by DREADD','Mean REM z-Score by DREADD'});

saveas(gcf,[filename(1:end-4),'_WR_zs_by_D.fig']);

figs=[];

p=zeros(2,1089);
h=zeros(2,1089);
z=zeros(2,1089);

for i=1:2, 
    
    for j=1:1089
        
        [p(i,j),h(i,j),stats]=ranksum(MI(states==state_indices(i),j),MI(states==3,j),'alpha',0.01/1089);
    
        z(i,j)=stats.zval;
        
    end

    temp_MI=reshape(z(i,:),33,33);
    
    figure(), imagesc(temp_MI)
    
    figs(i)=gcf;
    
    figure_replotter(gcf,1,1,4:.25:12,20:5:180,{[state_labels{state_indices(i)+1},' Ranksum z-Value by DREADD']})
    
    saveas(gcf,[filename(1:end-4),'_',state_labels{state_indices(i)+1},'_ranksum_zval_vs_DREADD.fig']);
    
end

figure_replotter(figs,1,2,4:.25:12,20:5:180,{'Wake vs. DREADD, Ranksum z-Value','REM vs. DREADD, Ranksum z-Value'});

saveas(gcf,[filename(1:end-4),'_WR_ranksum_zval_by_D.fig']);

figs=[];

z_sig=z;
z_sig(h==0)=nan;

for i=1:2
    
    figure(), colorplot(reshape(z_sig(i,:),33,33))
    
    figs(i)=gcf;
    
    figure_replotter(gcf,1,1,4:.25:12,20:5:180,{{[state_labels{state_indices(i)+1},' vs. DREADD'];'Significant Ranksum z-Value'}})
    
    saveas(gcf,[filename(1:end-4),'_',state_labels{state_indices(i)+1},'_ranksum_zval_vs_DREADD.fig']);
    
end

figure_replotter(figs,1,2,4:.25:12,20:5:180,{'Wake vs. DREADD, Significant Ranksum z-Value','REM vs. DREADD, Significant Ranksum z-Value'});

saveas(gcf,[filename(1:end-4),'_WR_ranksum_sig_zval_by_D.fig']);

DREADD_epochs=find(states==3);
no_reps=1000000;

corr_vec=zeros(2,no_reps);

for i=1:2,  

    state_epochs=find(states==state_indices(i));

    DREADD_choices=randi(length(DREADD_epochs),1,no_reps);
    state_choices=randi(length(state_epochs),1,no_reps);
    
    parfor j=1:no_reps
        
        DREADD_MI=MI(DREADD_epochs(DREADD_choices(j)),:);
        DREADD_MI=reshape(DREADD_MI,33,33);
        state_MI=MI(state_epochs(state_choices(j)),:);
        state_MI=reshape(state_MI,33,33);
        corr_vec(i,j)=max(max(xcorr2(DREADD_MI,state_MI)));
        
    end
    
end

save([filename(1:end-4),'_corr_',num2str(no_reps),'.mat'],'corr_vec')

figure(), boxplot(corr_vec')

saveas(gcf,[filename(1:end-4),'_corr_boxplot.fig'])

h_w=histc(corr_vec(1,:),linspace(0,.5,100));
h_r=histc(corr_vec(2,:),linspace(0,.5,100));

figure(), loglog(.0025:.005:(.5-.0025),([h_w; h_r]/1000000)')
legend({'Wake','REM'})
saveas(gcf,[filename(1:end-4),'_corr_hist.fig'])