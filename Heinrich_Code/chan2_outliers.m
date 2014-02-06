[listname,listpath]=uigetfile('*list','Choose list of epochs');

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

for i=1:filenum
    
    filename=char(filenames(i));
    data=load(filename);
    chan2=data(:,3);
%     emg=data(:,4);
    
    filename=[filename(1:end-4),'_chan2'];
%     data=reshape(data,length(data)/4,4);
%     data=data(:,3);
    fid=fopen([filename,'.txt'],'w');
    fprintf(fid,'%f\n',chan2);
    
%     Quants=quantile(data,[.25 .75]);
%     IQR=Quants(2)-Quants(1);
%     Low_lim=Quants(1)-3*IQR;
%     High_lim=Quants(2)+3*IQR;
%     
%     Outliers=(data>High_lim | data<Low_lim);
%     Outlier_locs=find(Outliers==1);
%     Outlier_vals=data(Outlier_locs);
%     
%     if ~isempty(Outlier_locs)
%         fid1=fopen([filename,'.outliers'],'w');
%         fprintf(fid1,'%d\t%f\n',[Outlier_locs Outlier_vals]');
%     end
    
    fclose('all');
   
%     t=[1:length(data)]/600;
%     t_outs=t;
%     t_outs(Outliers==0)=nan;
%     t_no_outs=t;
%     t_no_outs(Outlier_locs)=nan;
%     
%     data_outs=data;
%     data_outs(Outliers==0)=nan;
%     data_no_outs=data;
%     data_no_outs(Outlier_locs)=nan;
%     
%     plot(t_no_outs,data_no_outs,'k',t_outs,data_outs,'r');
%     title([filename,' Outliers'])
%     saveas(gcf,[filename,'_outliers.fig'])
%     close(gcf)
    
end