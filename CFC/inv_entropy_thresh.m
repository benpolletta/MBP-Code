function inv_entropy_thresh(filedir,noamps,nophases,x_lims,x_bins,y_lims,y_bins,spacing,units)
% function inv_entropy_thresh(x_lims,x_bins,y_lims,y_bins,spacing,units)

[listname,listpath]=uigetfile('*list','Choose list of file names.');
filenames=textread([listpath,listname],'%s%*[^\n]');

filenum=length(filenames);

[cutoffs_name,cutoffs_path]=uigetfile('*cutoffs.txt','Choose file of cutoff values.');
Cutoffs=load([cutoffs_path,cutoffs_name]);

[no_cutoffs,length_cutoffs]=size(Cutoffs);

if no_cutoffs==noamps & length_cutoffs==nophases
    Cutoffs=reshape(Cutoffs,1,noamps*nophases);
    Cutoffs=repmat(Cutoffs,filenum,1);
elseif no_cutoffs==1 & length_cutoffs==noamps*nophases
    Cutoffs=repmat(Cutoffs,filenum,1);
elseif no_cutoffs~=filenum
    display('Number of cutoffs must equal 1, noamps, or number of MI files.');
    return;
elseif length_cutoffs~=noamps*nophases
    display(['Length of cutoff vector must equal nophases = ',num2str(nophases),' or noamps*nophases = ',num2str(noamps*nophases)]);
    return;
end

Cutoff_dir=[cutoffs_path,cutoffs_name(1:end-4)];
mkdir (Cutoff_dir)

present_dir=pwd;

MI_thresh=zeros(noamps,nophases,filenum);

bMI_thresh=zeros(x_bins,y_bins,filenum);

for i=1:filenum

    filename=char(filenames(i));
    filename=filename(1:end-4);
    MI_filename=[filedir,'\MI_Data_Plots\',filename,'_inv_entropy.txt'];
%     F_filename=[filedir,'\HAF_Data_Plots\',filename,'\freqs.txt'];
    
    MI=load(MI_filename);
    bands_lo=MI(1,2:end);
    bands_hi=MI(2:end,1);
    MI=MI(2:end,2:end);
    
%     F=load(F_filename);
    
%     [noamps,nophases]=size(MI);
        
    Cutoff=reshape(Cutoffs(i,:),noamps,nophases);
    
    format=make_format(nophases,'f');
    
    mit=max(0,MI-Cutoff);
    MI_thresh(:,:,i)=mit;
    
    cd (Cutoff_dir)
    
    fid=fopen([filename,'_thresh.txt'],'w');
    fprintf(fid,format,mit');
    fclose(fid);
    
%     emd_inv_entropy_bMI_all(triu(mit,1),F,50,'linear',units,[filename,'_thresh']);
%     bMI_thresh(:,:,i)=emd_inv_entropy_plot_bMI(triu(mit,1),F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[filename,'_thresh']);

    close('all')
    fclose('all')
    
    cd (present_dir)

end

avg_MI_thresh=mean(MI_thresh,3);

fid=fopen([listname,'_thresh.txt'],'w');
fprintf(fid,format,avg_MI_thresh');
fclose(fid);

band_labels={'high gamma';'low gamma';'alpha, beta';'theta'};

figure(1)
colorplot(avg_MI_thresh)
title({['Mean MI for ',listname];['Thresholded by ',cutoffs_name]},'FontSize',24)
axis ij
set(gca,'XTick',[1.5:nophases+1.5],'YTick',[1.5:noamps+1.5],'XTickLabel',bands_lo,'YTickLabel',bands_hi,'FontSize',16)
xlabel(['Phase-Modulating Freq. (',char(units),')'],'FontSize',24)
ylabel(['Amplitude-Modulated Freq. (',char(units),')'],'FontSize',24)

% avg_bMI_thresh=mean(bMI_thresh,3);
% 
% bands_lo=makebands(x_bins,x_lims(1),x_lims(2),spacing);
% bands_hi=makebands(y_bins,y_lims(1),y_lims(2),spacing);
% 
% figure(2)
% colorplot(avg_bMI_thresh)
% title({['Mean Binned MI for ',listname];['Thresholded by ',cutoffs_name]},'FontSize',24)
% axis xy
% set(gca,'XTick',[1.5:x_bins+1.5],'YTick',[1.5:y_bins+1.5],'XTickLabel',bands_lo(:,2),'YTickLabel',bands_hi(:,2),'FontSize',16)
% xlabel(['Phase-Modulating Freq. (',char(units),')'],'FontSize',24)
% ylabel(['Amplitude-Modulated Freq. (',char(units),')'],'FontSize',24)

cd (Cutoff_dir)

saveas(1,[listname,'_avg_MI.fig'])
% saveas(2,[listname,'_avg_bMI.fig'])

cd (present_dir)