function [amplitude,s,s_plus]=make_CFC_signal_1mode(low_freq,hi_freq,amplitude_low,amplitude_hi,phase_low,phase_hi,coupling_phase,c,signal_length,outfilename)

t=1:signal_length;
s=zeros(1,signal_length);

figure();

lowmode=amplitude_low*exp(sqrt(-1)*2*pi*(low_freq*t-phase_low));
subplot(4,2,1);
plot(t,real(lowmode));

%c=rand+.2;

amplitude=amplitude_hi*exp(-(mod(phase(lowmode)-(coupling_phase-pi),2*pi)-pi).^2/(2*c^2))+.2;
subplot(4,2,3);
plot(t,amplitude);

himode=amplitude.*exp(sqrt(-1)*2*pi*(hi_freq*t-phase_hi));
subplot(4,2,5);
plot(t,real(himode));

s=lowmode+himode;
subplot(4,2,7);
plot(t,real(s));

noise=rand*100*randn(1,signal_length);
subplot(4,2,2);
plot(t,noise);

bend=floor(rand*signal_length);
slopes=rand(1,2)*4-2;
int=rand*50-25;
trend1=slopes(1)*3*t(1:bend)+int;
trend2=slopes(2)*3*(t(bend+1:end)-(bend+1))+trend1(end);
trend=[trend1 trend2];
subplot(4,2,4);
plot(t,trend);

s_plus=s+noise+trend;
subplot(4,2,6);
plot(t,real(s_plus));


if nargin>=3
    saveas(gcf,[char(outfilename),'.fig']);
    fid=fopen([char(outfilename),'_amplitude.txt'],'w');
    fprintf(fid,'%f\n',amplitude);
    fid=fopen([char(outfilename),'_signal.txt'],'w');
    fprintf(fid,'%f\n',real(s));
    fid=fopen([char(outfilename),'_w_noise.txt'],'w');
    fprintf(fid,'%f\n',real(s_plus));
end

fclose(fid);