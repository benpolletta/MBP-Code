function [MI]=CFC_He_fft_batch(datalist,sampling_freq,range_lo,range_hi,nobands_lo,nobands_hi,nobins)

MI=[];

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

for i=1:filenum
    M=[]; mi=[];
    [M,mi]=CFC_He_fft(char(filenames(i)),sampling_freq,range_lo,range_hi,nobands_lo,nobands_hi,nobins);
    MI(:,:,i)=mi;
end