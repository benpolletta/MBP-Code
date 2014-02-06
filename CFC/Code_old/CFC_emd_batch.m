function CFC_emd_batch(datalist,sampling_freq,nobins)

MI=[];

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

for i=1:filenum
    H=[]; A=[]; P=[]; M=[]; mi=[]; PAC=[]; mag=[]; dir=[]; Rho=[]; Rho1=[]; n=[]; m=[];
    [H,A,P,M,mi,PAC,mag,dir,Rho,Rho1,n,m]=CFC_emd(char(filenames(i)),sampling_freq,nobins);
end