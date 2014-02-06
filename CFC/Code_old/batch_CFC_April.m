function batch_CFC_April(datalist,sampling_freq,min_cycles,nobins,noshufs,p_threshold,z_threshold,x_lims,x_bins,y_lims,y_bins,units)

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

dirnames{1}='HAF_Data_Plots';
dirnames{2}='AVP_Data';
dirnames{3}='AVP_Plots';
dirnames{4}='MI_Data_Plots';
for i=1:4
    mkdir (dirnames{i});
end

for j=1:filenum
    H=[]; A=[]; F=[]; bands=[]; M=[]; MI=[]; MI_p_vals=[]; MI_z_scores=[]; Percent_MI=[];
    [bands,MI,MI_p_vals,MI_z_scores,Percent_MI]=CFC_April(char(filenames(j)),sampling_freq,min_cycles,nobins,noshufs,p_threshold,z_threshold,x_lims,x_bins,y_lims,y_bins,units,dirnames);
%     Max_MI(j)=max(max(MI_good));
%     [R,C]=find(MI_good==Max_MI);
%     Peak_phase_freq(j)=bands(C,2);
%     Peak_amp_freq(j)=bands(R,2);
%     [r,c]=max(Percent_MI);
%     Peak_phase_bin(j)=
    close('all')
    fclose('all')
end
