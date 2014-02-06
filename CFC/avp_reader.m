function [avp,phase_bands,amp_bands,bin_centers]=avp_reader(avp_list)

filenames=textread(char(avp_list),'%s%*[^\n]');
filenum=length(filenames);

for i=1:filenum
    avp_mat=load(char(filenames(i)));
    phase_bands(i)=avp_mat(1,1);
    avp(:,:,i)=avp_mat(2:end,2:end);
    bin_centers=avp_mat(2:end,1);
    amp_bands=avp_mat(1,2:end);
end