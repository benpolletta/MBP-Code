function inv_entropy_thresh_emd(noamps,nophases,x_lims,x_bins,y_lims,y_bins,spacing,units)
% function inv_entropy_thresh(x_lims,x_bins,y_lims,y_bins,spacing,units)

[listname,listpath]=uigetfile('*list','Choose list of file names.');
filenames=textread([listpath,listname],'%s%*[^\n]');

filenum=length(filenames);

[cutoffs_name,cutoffs_path]=uigetfile('*cutoffs.txt','Choose file of cutoff values.');
Cutoffs=textread([cutoffs_path,cutoffs_name],'','delimiter','\t','emptyvalue',NaN);

[no_cutoffs,length_cutoffs]=size(Cutoffs);

if no_cutoffs==noamps & length_cutoffs==nophases
    Cutoffs=reshape(Cutoffs,1,noamps*nophases);
    Cutoffs=repmat(Cutoffs,filenum,1);
elseif no_cutoffs==1
    Cutoffs=repmat(Cutoffs,filenum,1);
elseif no_cutoffs~=filenum
    display('Warning: number of cutoffs must equal 1, noamps, or number of MI files.');
elseif length_cutoffs~=noamps*nophases
    display(['Warning: length of cutoff vector must equal nophases = ',num2str(nophases),' or noamps*nophases = ',num2str(noamps*nophases)]);
end

Cutoff_dir=[cutoffs_path,cutoffs_name(1:end-4)];
mkdir (Cutoff_dir)

present_dir=pwd;

MI_bands=nan(filenum,max(noamps,nophases));

MI_thresh=nan(noamps,nophases,filenum);

bMI_thresh=zeros(x_bins,y_bins,filenum);

for i=1:filenum

    filename=char(filenames(i));
    filename=filename(1:end-8);
    MI_filename=['EMD\MI_Data_Plots\',filename,'_inv_entropy.txt'];
    F_filename=['EMD\HAF_Data_Plots\',filename,'_freqs.txt'];
    
    MI=load(MI_filename);
    bands=MI(1,2:end);
    MI=MI(2:end,2:end);
    [MI_rows,MI_cols]=size(MI);
    
    F=load(F_filename);
    F=F(2:end,:);
    
%     [noamps,nophases]=size(MI);
        
    Cutoff=reshape(Cutoffs(i,1:MI_rows*MI_cols),MI_rows,MI_cols);
    
    format=make_format(MI_cols,'f');
    
    mit=max(0,MI-Cutoff);
    MI_thresh(1:MI_rows,1:MI_cols,i)=mit;
    MI_bands(i,1:length(bands))=bands;
    
    cd (Cutoff_dir)
    
    fid=fopen([filename,'_thresh.txt'],'w');
    fprintf(fid,format,mit');
    fclose(fid);
    
    emd_inv_entropy_bMI_all(triu(mit,1),F,50,'linear',units,[filename,'_thresh']);
    bMI_thresh(:,:,i)=emd_inv_entropy_plot_bMI(triu(mit,1),F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[filename,'_thresh']);

    close('all')
    fclose('all')
    
    cd (present_dir)

end

avg_MI_bands=nanmean(MI_bands);
for i=1:length(avg_MI_bands)
    band_labels{i}=num2str(avg_MI_bands(i));
end

avg_MI_thresh=nanmean(MI_thresh,3);

% band_labels={'high gamma';'low gamma';'alpha, beta';'theta'};

figure(1)
colorplot(triu(avg_MI_thresh,1))
title({['Mean MI for ',listname];['Thresholded by ',cutoffs_name]},'FontSize',24)
axis ij
set(gca,'XTick',[1.5:nophases+1.5],'YTick',[1.5:noamps+1.5],'XTickLabel',band_labels,'YTickLabel',band_labels,'FontSize',16)
xlabel(['Phase-Modulating Freq. (',char(units),')'],'FontSize',24)
ylabel(['Amplitude-Modulated Freq. (',char(units),')'],'FontSize',24)

avg_bMI_thresh=mean(bMI_thresh,3);

bands_lo=makebands(x_bins,x_lims(1),x_lims(2),spacing);
bands_hi=makebands(y_bins,y_lims(1),y_lims(2),spacing);

figure(2)
colorplot(avg_bMI_thresh)
title({['Mean Binned MI for ',listname];['Thresholded by ',cutoffs_name]},'FontSize',24)
axis xy
set(gca,'XTick',[1.5:x_bins+1.5],'YTick',[1.5:y_bins+1.5],'XTickLabel',bands_lo(:,2),'YTickLabel',bands_hi(:,2),'FontSize',16)
xlabel(['Phase-Modulating Freq. (',char(units),')'],'FontSize',24)
ylabel(['Amplitude-Modulated Freq. (',char(units),')'],'FontSize',24)

cd (Cutoff_dir)

saveas(1,[listname,'_avg_MI.fig'])
saveas(2,[listname,'_avg_bMI.fig'])

cd (present_dir)