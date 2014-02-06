function [All_pZS]=batch_pZS(datalist,Z_dir,F_dir,x_lims,x_bins,y_lims,y_bins,units)

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

for i=1:filenum
    Zfilename=[char(Z_dir),'\',char(filenames(i)),'_inv_entropy_zscores.txt'];
    Ffilename=[char(F_dir),'\',char(filenames(i)),'_freqs.txt'];
    
    ZS=load(Zfilename);
    ZS=ZS(2:end,2:end);
    
    F=load(Ffilename);
    F=F(2:end,:);

    All_pZS(:,:,i)=emd_inv_entropy_plot_pZS(ZS,F,x_lims,x_bins,y_lims,y_bins,units,char(filenames(i)));
end