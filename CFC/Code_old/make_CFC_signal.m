function [s]=make_CFC_signal(nomodes,signal_length,outfilename)

lowmodes=[];
himodes=[];

t=1:signal_length;
s=zeros(1,signal_length);

wavelengths_low=rand(1,nomodes)*(signal_length/2-signal_length/100)+signal_length/100;
freqs_low=1./wavelengths_low;
amplitudes_low=rand(1,nomodes)*100;
phases_low=rand(1,nomodes)*2*pi;

figure();

for i=1:nomodes
    lowmodes(i,:)=amplitudes_low(i)*exp(sqrt(-1)*2*pi*(t/wavelengths_low(i)-phases_low(i)));
    subplot(nomodes,3,3*i-2);
    plot(t,real(lowmodes(i,:)));
end

wavelengths_hi=rand(1,nomodes)*(signal_length/100-1)+1;
freqs_hi=1./wavelengths_hi;
amplitudes_hi=rand(1,nomodes)*100;
phases_hi=rand(1,nomodes)*2*pi;
coupling_phases=rand(1,nomodes)*2*pi;

for i=1:nomodes
    c=rand*3+.2;
    amplitude=amplitudes_hi(i)*exp(-(mod(phase(lowmodes(i,:))-(coupling_phases(i)-pi),2*pi)-pi).^2/(2*c^2));
    himodes(i,:)=amplitude.*exp(sqrt(-1)*2*pi*(t/wavelengths_hi(i)-phases_hi(i)));
    subplot(nomodes,3,3*i-1);
    plot(t,amplitude);
    subplot(nomodes,3,3*i);
    plot(t,real(himodes(i,:)));
end
    
s=sum(lowmodes)+sum(himodes);

if nargin>=3
    saveas(gcf,[char(outfilename),'_decomp.fig']);
    fid1=fopen([char(outfilename),'.txt'],'w');
    fprintf(fid1,'%f\n',s);
    fid2=fopen([char(outfilename),'_couplings.txt'],'w');
    fprintf(fid2,'%f\t%f\t%f\n',[freqs_low; freqs_hi; coupling_phases]);
end

figure();
plot(t,real(s));

if nargin>=3
    saveas(gcf,[outfilename,'.fig']);
end