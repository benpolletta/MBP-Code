function MI=batch_CFC_April_fft(datalist,sampling_freq,nobins,noshufs,p_threshold,z_threshold,x_lims,x_bins,y_lims,y_bins,buttorder,pctpass,units)

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

dirnames{1}='FFT\HAF_Data_Plots';
dirnames{2}='FFT\AVP_Data';
dirnames{3}='FFT\AVP_Plots';
dirnames{4}='FFT\MI_Data_Plots';
for i=1:4
    mkdir (dirnames{i});
end

MI=zeros(y_bins,x_bins,filenum,4);

for j=1:filenum
    clear('MI_good','MI_p_vals','Percent_MI');
    [bands_lo,bands_hi,MI(:,:,j,1),MI(:,:,j,2),MI(:,:,j,3),MK(:,:,j,4)]=CFC_April_fft(char(filenames(j)),sampling_freq,nobins,noshufs,p_threshold,z_threshold,x_lims,x_bins,y_lims,y_bins,buttorder,pctpass,units,dirnames);
%     Max_MI(j)=max(max(MI_good));
%     [R,C]=find(MI_good==Max_MI);
%     Peak_phase_freq(j)=bands(C,2);
%     Peak_amp_freq(j)=bands(R,2);
%     [r,c]=max(Percent_MI);
%     Peak_phase_bin(j)=
    close('all')
    fclose('all')
end
