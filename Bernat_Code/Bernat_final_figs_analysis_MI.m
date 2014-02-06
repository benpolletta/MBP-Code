function Bernat_final_figs_analysis_MI

x_ticks=1:.25:12; y_ticks=20:5:200;
matrix_rows=length(y_ticks); matrix_columns=length(x_ticks);

[filename,filepath]=uigetfile('*MI.txt','Choose file containing collected MI.');
[periodname,periodpath]=uigetfile('*periods.txt','Choose file containing periods.');
[subjname,subjpath]=uigetfile('*subjects.txt','Choose file containing subjects.');

MI=load([filepath,filename]);
% [rows,cols]=size(MI);
periods=textread([periodpath,periodname],'%s');
subjects=textread([subjpath,subjname],'%s');

p=1;
for i=4:-1:1
    period_labels{p}=['Hour ',num2str(i),' Preinjection'];
    short_period_labels{p}=['pre',num2str(i)];
    p=p+1;
end
for i=1:12
    period_labels{p}=['Hour ',num2str(i),' Postinjection'];
    short_period_labels{p}=['post',num2str(i)];
    p=p+1;
end
no_periods=length(period_labels);

subj_labels={'A99','A102','A103','A104','A105','A106'};
no_subjects=length(subj_labels);

% median_MI=zeros(matrix_rows,matrix_columns,no_periods);
% mean_MI=zeros(matrix_rows,matrix_columns,no_periods);
% std_MI=zeros(matrix_rows,matrix_columns,no_periods);

fig_dir=filename(1:end-7);
mkdir (fig_dir)

% %%%%%%%%%%%%%%%%%%% MEDIAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all')

figs=[];

for p=1:no_periods 
    
    short_period_label=char(short_period_labels{p});
    
    MI_temp=reshape(nanmedian(MI(strcmp(periods,short_period_label)==1,:)),matrix_rows,matrix_columns); 
    
    figure(), imagesc(MI_temp)
    
    figs(p)=gcf;
    
    handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,['Median ',period_labels{p}]);
    
    saveas(handl,[fig_dir,'/',filename(1:end-4),'_',short_period_labels{p},'_median.fig']);
    
%     median_MI(:,:,p)=MI_temp; 

end

figure_replotter(figs,4,4,x_ticks,y_ticks,period_labels);

saveas(gcf,[fig_dir,'/',filename(1:end-4),'_median.fig']);

% %%%%%%%%%%%%%%%%%%%%% MEAN FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all')

figs=[];

for p=1:no_periods 
    
    short_period_label=char(short_period_labels{p});
    
    MI_temp=reshape(nanmean(MI(strcmp(periods,short_period_label)==1,:)),matrix_rows,matrix_columns); 
    
    figure(), imagesc(MI_temp)
    
    figs(p)=gcf;
    
    handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,['Mean ',period_labels{p}]);
    
    saveas(handl,[fig_dir,'/',filename(1:end-4),'_',short_period_labels{p},'_mean.fig']);
    
%     mean_MI(:,:,p)=MI_temp; 

end

figure_replotter(figs,4,4,x_ticks,y_ticks,period_labels);

saveas(gcf,[fig_dir,'/',filename(1:end-4),'_mean.fig']);

% %%%%%%%%%%%%%%%%%%%%%% STD FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all')

figs=[];

for p=1:no_periods 
    
    short_period_label=char(short_period_labels{p});
    
    MI_temp=reshape(nanstd(MI(strcmp(periods,short_period_label)==1,:)),matrix_rows,matrix_columns); 
    
    figure(), imagesc(MI_temp)
    
    figs(p)=gcf;
    
    handl=figure_replotter(figs(p),1,1,x_ticks,y_ticks,['Standard Deviation ',period_labels{p}]);
    
    saveas(handl,[fig_dir,'/',filename(1:end-4),'_',short_period_labels{p},'_std.fig']);
    
%     std_MI(:,:,p)=MI_temp; 

end

figure_replotter(figs,4,4,x_ticks,y_ticks,period_labels);

saveas(gcf,[fig_dir,'/',filename(1:end-4),'_std.fig']);