function [avg_MI_zt,max_MI_zt_bands]=fft_MI_zthresh_plotter_missing_MI(datalist,figlist,charstoskip,MI_dir,Agg_dir,x_lims,x_bins,y_lims,y_bins,spacing,units)

present_dir=pwd;

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

fignames=textread(figlist,'%s%*[^\n]');
fignum=length(fignames);

if fignum~=filenum
    display('The number of data files and the number of figures must be the same.')
end

bands_lo=makebands(x_bins,x_lims(1),x_lims(2),'linear');
bands_lo=bands_lo(:,2);
bands_hi=makebands(y_bins,y_lims(1),y_lims(2),'linear');
bands_hi=bands_hi(:,2);

format='';
for j=1:x_bins
    format=[format,'%f\t'];
end
format=[format,'%f\n'];

All_MI_zt=zeros(y_bins,x_bins,filenum);
max_MI_zt_bands=zeros(filenum,2);

for i=1:filenum
    
    filename=char(filenames(i));
    figname=char(fignames(i));
    
    cd (char(MI_dir))
    
%     MIfilename=[char(MI_dir),'\',filename,'_a_15_from_20_to_110_v_p_15_fr
%     om_3_to_9_inv_entropy.txt'];
    
    filename=filename(1:end-charstoskip);
    Zfilename=[filename,'_inv_entropy_zscores.txt'];
%     Ffilename=[char(F_dir),'\',filename,'\',filename,'_freqs.txt'];
    
    open(figname);
    axes=findall(gcf,'Type','axes');
    Chilluns=get(axes(end),'Children');
    MI=get(Chilluns,'CData');
    MI=MI(1:end-1,1:end-1);
    close(gcf);
    [r,c]=size(MI);
    
    fid=fopen([filename,'_inv_entropy.txt'],'w');
    fprintf(fid,format,[NaN bands_lo'; bands_hi MI]');
    fclose(fid);
    
    ZS=load(Zfilename);
    ZS=ZS(2:end,2:end);
    
    MI_zthresh=MI;
    z_threshold=.05/nchoosek(c,2);
    MI_zthresh(normcdf(ZS,0,1)<1-z_threshold)=0;
    All_MI_zt(:,:,i)=MI_zthresh;
    
    maxMIzt=max(max(MI_zthresh));
    [r,c]=find(MI_zthresh==maxMIzt);
    max_MI_zt_bands(i,1)=mean(bands_hi(r));
    max_MI_zt_bands(i,2)=mean(bands_lo(c));

    fid1=fopen([filename,'_inv_entropy_zthresh.txt'],'w');
    fprintf(fid1,format,[NaN bands_lo'; bands_hi MI_zthresh]');
    fclose(fid1);
    
    figure()
    colorplot(MI_zthresh)
    axis xy
    title(['MI Values with z-Score Higher than ',z_threshold],'FontSize',30)
    set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',bands_lo,'YTickLabel',bands_hi,'FontSize',16)
    xlabel(['Phase-Modulating Freq. (Hz)'],'FontSize',24)
    ylabel(['Amplitude-Modulated Freq. (Hz)'],'FontSize',24)
    saveas(gcf,[filename,'_inv_entropy_zthresh.fig'])
    
    cd (present_dir);
    
    close(gcf);
    
end

avg_MI_zt=mean(All_MI_zt,3);

cd (char(Agg_dir));

fid=fopen([datalist,'_avg_MI_zt.txt'],'w');
fprintf(fid,format,[NaN bands_lo'; bands_hi avg_MI_zt]');
fclose(fid)

figure()
colorplot(avg_MI_zt)
title(['Mean Binned Thresholded MI for ',datalist],'FontSize',30)
axis xy
set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',bands_lo,'YTickLabel',bands_hi,'FontSize',16)
xlabel(['Phase-Modulating Freq. (',char(units),')'],'FontSize',24)
ylabel(['Amplitude-Modulated Freq. (',char(units),')'],'FontSize',24)
saveas(gcf,[datalist,'_avg_MI_zt.fig'])

figure()
colormap('gray')
colorplot(avg_MI_zt)
axis xy
set(gca,'XTick',[1.5 8.5 15.5],'YTick',[1.5 8.5 15.5],'XTickLabel',[bands_lo(1) bands_lo(8) bands_lo(15)],'YTickLabel',[bands_hi(1) bands_hi(8) bands_hi(15)],'FontSize',16)
saveas(gcf,[datalist,'_avg_MI_zt_minimal.fig'])

cd (present_dir);