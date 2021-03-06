function [All_bMI,avg_bMI]=batch_bMI_missing_MI(datalist,figlist,charstoskip,MI_dir,F_dir,x_lims,x_bins,y_lims,y_bins,units)

present_dir=pwd;

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

fignames=textread(figlist,'%s%*[^\n]');
fignum=length(fignames);

if fignum~=filenum
    display('The number of data files and the number of figures must be the same.')
end

bands_lo=makebands(x_bins,x_lims(1),x_lims(2),'linear');
bands_hi=makebands(y_bins,y_lims(1),y_lims(2),'linear');

format='';
for j=1:x_bins-1
    format=[format,'%f\t'];
end
format=[format,'%f\n'];

for p=1:y_bins
    A_labels{p}=num2str(bands_hi(p,2));
end

for p=1:x_bins
    P_labels{p}=num2str(bands_lo(p,2));
end

All_bMI=zeros(y_bins,x_bins,filenum);

for i=1:filenum
    
    filename=char(filenames(i));
    figname=char(fignames(i));
    
    filename=filename(1:end-charstoskip);
    
    cd (F_dir)
    
    Ffilename=[filename,'\freqs.txt'];
    F=load(Ffilename);
    
    cd (present_dir)
    
    cd (MI_dir)
    
    open(figname);
    axes=findall(gcf,'Type','axes');
    Chilluns=get(axes(end),'Children');
    MI=get(Chilluns,'CData');
    MI=MI(1:end-1,1:end-1);
    close(gcf);
    
    [r,c]=size(MI);
    
    MI_format='';
    for k=1:c-1
        MI_format=[MI_format,'%f\t'];
    end
    MI_format=[MI_format,'%f\n'];
    
    fid=fopen([filename,'_inv_entropy.txt'],'w');
    fprintf(fid,MI_format,MI');
    fclose(fid);
    
    MI=triu(MI,1);
    
%     Zfilename=[char(MI_dir),'\',filename,'_inv_entropy_zscores.txt'];
    Zfilename=[filename,'_inv_entropy_zscores.txt'];
    ZS=load(Zfilename);
    ZS=triu(ZS(2:end,2:end),1);
    
    if size(ZS)~=size(MI)
        display(['For ',filename,' size of ZS is [',num2str(size(ZS)),'] and for ',figname,' size of MI is [',num2str(size(MI)),']:'])
        display(ZS)
        display(MI)
    end
    
    MI_zthresh=MI;
    z_threshold=.05/nchoosek(c,2);
    MI_zthresh(normcdf(ZS,0,1)<1-z_threshold)=0;
    
    bMI=emd_inv_entropy_plot_bMI(MI_zthresh,F,x_lims,x_bins,y_lims,y_bins,'linear',units,filename);
    All_bMI(:,:,i)=bMI;
    
    cd (present_dir);
    
    close(gcf);
end

avg_bMI=mean(All_bMI,3);

cd (char(MI_dir));

fid=fopen([datalist,'_avg_bMI.txt'],'w');
fprintf(fid,format,avg_bMI');
fclose(fid)

figure()
colormap('jet')
colorplot(avg_bMI)
title(['Mean Binned Thresholded MI for ',datalist],'FontSize',30)
axis xy
set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
xlabel(['Phase-Modulating Freq. (',char(units),')'],'FontSize',24)
ylabel(['Amplitude-Modulated Freq. (',char(units),')'],'FontSize',24)
saveas(gcf,[datalist,'_avg_bMI.fig'])

figure()
colormap('gray')
colorplot(avg_bMI)
axis xy
set(gca,'XTick',[1.5 8.5 15.5],'YTick',[1.5 8.5 15.5],'XTickLabel',[P_labels(1) P_labels(8) P_labels(15)],'YTickLabel',[A_labels(1) A_labels(8) A_labels(15)],'FontSize',16)
saveas(gcf,[datalist,'_avg_bMI_minimal.fig'])


cd (present_dir);