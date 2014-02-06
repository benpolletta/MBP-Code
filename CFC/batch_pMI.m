function [All_pMI]=batch_pMI(datalist,MI_dir,F_dir,x_lims,x_bins,y_lims,y_bins,units)

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

bands_lo=makebands(x_bins,x_lims(1),x_lims(2),'linear');
bands_hi=makebands(y_bins,y_lims(1),y_lims(2),'linear');

for p=1:15
    A_labels{p}=num2str(bands_hi(p,2));
    P_labels{p}=num2str(bands_lo(p,2));
end

for i=1:filenum
    Zfilename=[char(MI_dir),'\',char(filenames(i)),'_inv_entropy_pvals.txt'];
    Ffilename=[char(F_dir),'\',char(filenames(i)),'_freqs.txt'];
    
    MI=load(Zfilename);
    MI=MI(2:end,2:end);
    
    F=load(Ffilename);
    F=F(2:end,:);

    All_pMI(:,:,i)=emd_inv_entropy_plot_pMI(MI,F,x_lims,x_bins,y_lims,y_bins,units,char(filenames(i)));
end

avg_pMI=mean(All_pMI,3);
[r,c]=size(avg_pMI);

format='';
for j=1:c-1
    format=[format,'%f\t'];
end
format=[format,'%f\n'];

fid=fopen([datalist,'_avg_pMI.txt'],'w');
fprintf(fid,format,avg_pMI');

colorplot(avg_pMI)
title(['Mean Percent MI for ',datalist],'FontSize',30)
axis xy
set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
xlabel('Phase-Modulating Freq. (Hz)','FontSize',24)
ylabel('Amplitude-Modulated Freq. (Hz)','FontSize',24)
saveas(gcf,[datalist,'_avg_pMI.fig'])