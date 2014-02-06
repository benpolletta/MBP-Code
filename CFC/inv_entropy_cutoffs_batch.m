function inv_entropy_cutoffs_batch(threshold)

[listname,listpath]=uigetfile('*list','Choose a list of files to compute cutoffs.')

cd (listpath)

filenames=textread(listname,'%s');
filenum=length(filenames);

P_thresh_file=[listname(1:end-5),'_p_',num2str(threshold),'_cutoffs.txt'];
fid1=fopen(P_thresh_file,'w');

Z_thresh_file=[listname(1:end-5),'_z_',num2str(threshold),'_cutoffs.txt'];
fid2=fopen(Z_thresh_file,'w');

LZ_thresh_file=[listname(1:end-5),'_lz_',num2str(threshold),'_cutoffs.txt'];
fid3=fopen(LZ_thresh_file,'w');

for i=1:filenum

    filename=char(filenames(i));
    MIvals=load(filename);
    
    [noshufs,nomeasures]=size(MIvals);
    
    format=make_format(nomeasures,'f');
    
    MI_pt_vals=quantile(MIvals,threshold);
    fprintf(fid1,format,MI_pt_vals);

    MI_means=mean(MIvals);
    MI_stds=std(MIvals);
    MI_zt_vals=MI_means+norminv(threshold,0,1)*MI_stds;
    fprintf(fid2,format,MI_zt_vals);

    MI_logmeans=mean(log(MIvals));
    MI_logstds=std(log(MIvals));
    MI_lzt_vals=exp(MI_logmeans+norminv(threshold,0,1)*MI_logstds);
    fprintf(fid3,format,MI_lzt_vals);
    
end

fclose('all')