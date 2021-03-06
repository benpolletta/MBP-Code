whitebg('w')

[raw_filename,raw_pathname]=uigetfile('*rep47.txt','Choose Raw File To Plot');

t=[1:1800]/600;

sample_data=load([raw_pathname,raw_filename]);
sample_length=length(sample_data);

dirname=[raw_pathname,'Sample_Signal_Figures'];

mkdir (dirname)

plot(t,sample_data(1:1800),'k')
box off
set(gca,'XTickLabel','','YTickLabel','')
saveas(gcf,[dirname,'\',raw_filename(1:end-4),'.fig'])

[list_filename,list_pathname]=uigetfile('*list','Choose List of Raw Files');
% fft_pathname=uigetdir('','Choose Directory of FFT files');

filenames=textread([list_pathname,list_filename],'%s');
filenum=length(filenames);
fft_all=zeros(filenum,sample_length/2);

f=2*600*[1:(sample_length/2)]/sample_length;

% Making FFT Figure.

for i=1:filenum
    filename=char(filenames(i));
%     filename=filename(1:end-4);
%     data_hat=load([fft_pathname,'\',filename,'_fft.txt']);
    data=load(filename);
    data_hat=fft(data)';
    fft_all(i,:)=data_hat(1:sample_length/2);
%     plot(f(1:floor(sample_length/2)),abs(data_hat(1:floor(sample_length/2))),'k')
%     hold on
end
avg_fft=mean(fft_all);
figure
plot(f(1:floor(sample_length/2)),abs(data_hat(1:floor(sample_length/2))),'r')
box off
set(gca,'XTickLabel','','YTickLabel','')
saveas(gcf,[filename(1:end-4),'_fft.fig'])
hold off

cd (raw_pathname)

% Makes He_BW figure.

[He_low_filename,He_low_pathname]=uigetfile('*modes.txt, *sigs.txt','Choose He BW Low Modes');

low_modes=load([He_low_pathname,He_low_filename]);
[junk,no_low_modes]=size(low_modes);

[He_hi_filename,He_hi_pathname]=uigetfile('*modes.txt, *sigs.txt','Choose He BW High Modes');

hi_modes=load([He_hi_pathname,He_hi_filename]);
[junk,no_hi_modes]=size(hi_modes);


fft_bands_lo=makebands(15,3,9,'linear');
fft_bands_hi=makebands(15,20,110,'linear');

figure
plot(low_modes(1:1800,:)+ones(1800,1)*(1:15));

figure
for i=1:no_low_modes
    subplot(no_low_modes+no_hi_modes,1,i)
    plot(t,low_modes(1:1800,i),'k')
    box off
%     set(gca,'YLabel',{num2str(fft_bands_lo(i,2));'Hz'},'XTickLabel','','YTickLabel','')
end

for i=1:no_hi_modes
    subplot(no_low_modes+no_hi_modes,1,no_low_modes+i)
    plot(t,hi_modes(1:1800,i),'k')
    box off
%     set(gca,'YLabel',{num2str(fft_bands_hi(i,2));'Hz'},'XTickLabel','','YTickLabel','')
end

saveas(gcf,[dirname,filename(1:end-4),'_He.fig'])

% Makes Matlab BW figure.

low_modes=[]; hi_modes=[];

[Mlab_low_filename,Mlab_low_pathname]=uigetfile('*modes.txt, *sigs.txt','Choose Mlab BW Low Modes');

low_modes=load([Mlab_low_pathname,Mlab_low_filename]);
[no_low_modes,junk]=size(low_modes);

[Mlab_hi_filename,Mlab_hi_pathname]=uigetfile('*modes.txt, *sigs.txt','Choose Mlab BW High Modes');

hi_modes=load([Mlab_hi_pathname,Mlab_hi_filename]);
[no_hi_modes,junk]=size(hi_modes);

for i=1:no_low_modes
    subplot(no_low_modes+no_hi_modes,1,i)
    plot(t,low_modes(1:1800,i),'k')
    box off
%     set(gca,'YLabel',{num2str(fft_bands_lo(i,2));'Hz'},'XTickLabel','','YTickLabel','')
end

for i=1:no_hi_modes
    subplot(no_low_modes+no_hi_modes,1,no_low_modes+i)
    plot(t,hi_modes(1:1800,i),'k')
    box off
%     set(gca,'YLabel',{num2str(fft_bands_hi(i,2));'Hz'},'XTickLabel','','YTickLabel','')
end

saveas(gcf,[dirname,'\',raw_filename(1:end-4),'_Mlab.fig'])

% Makes Filter Bank Figure.

[Fbank_filename,Fbank_pathname]=uigetfile('*modes.txt, *sigs.txt','Choose Fbank Modes');

modes=load([Fbank_pathname,Fbank_filename]);
[no_modes,junk]=size(modes);

for i=1:no_modes
    subplot(no_modes,1,i)
    plot(t,modes(1:1800,i),'k')
    box off
%     set(gca,'YLabel',{'Band';num2str(i)},'XTickLabel','','YTickLabel','')
end

saveas(gcf,[dirname,'\',raw_filename(1:end-4),'_Fbank.fig'])

% Makes EMD Figure.

[EMD_filename,EMD_pathname]=uigetfile('*modes.txt, *sigs.txt','Choose EMD Modes');

modes=load([EMD_pathname,EMD_filename]);
[no_modes,junk]=size(modes);

H=hilbert(modes');
P=inc_phase(H);
[F,cycle_bounds,bands,cycle_freqs]=cycle_by_cycle_freqs(P,600);

for i=1:length(cycle_bounds)
    nocycles(i)=length(cycle_bounds{i});
end
reliable_modes=find(nocycles>=5);

modes=modes(reliable_modes,:);
no_modes=length(reliable_modes);

for i=1:no_modes
    subplot(no_modes,1,i)
    plot(t,modes(1:1800,i),'k')
    box off
%     set(gca,'YLabel',{'Mode';num2str(i)},'XTickLabel','','YTickLabel','')
end

saveas(gcf,[dirname,'\',raw_filename(1:end-4),'_EMD.fig'])