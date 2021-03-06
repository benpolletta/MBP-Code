function [noise,low_mode,amp_hi,hi_mode,s,s_noise]=simulateCFC(length,sampling_freq,f_lo,f_hi,strength,noise_level)

noise=randn(1,length)*noise_level;

t=1:length;
t=t/sampling_freq;

low_mode=sin(2*pi*f_lo*t);

amp_hi=.5*(strength*low_mode+2-strength);

hi_mode=amp_hi.*sin(2*pi*f_hi*t);

s=low_mode+hi_mode;

s_noise=low_mode+hi_mode+noise;

fid=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'.txt'],'w');
fid1=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_noise_',num2str(noise_level),'.txt'],'w');
fid2=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_noise_',num2str(noise_level),'_decomp.txt'],'w');

fprintf(fid,'%f\n',s);
fprintf(fid1,'%f\n',s_noise);
fprintf(fid2,'%f\t%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode; noise]);