function simulateCFC_pink_noise_reps(simlength,sampling_freq,f_lo,f_hi,strength,noise_level,noreps)

t=1:simlength;
t=t/sampling_freq;

low_mode=sin(2*pi*f_lo*t);

amp_hi=.5*(strength*low_mode+2-strength);

hi_mode=amp_hi.*sin(2*pi*f_hi*t);

s=low_mode+hi_mode;

fid=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'.txt'],'w');
fprintf(fid,'%f\n',s);

fid2=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_decomp.txt'],'w');
fprintf(fid2,'%f\t%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode]);

fclose('all')

for i=1:noreps

    f=sampling_freq*[1:simlength/2+1]/simlength;
    f_inv_norm=(f.^(-1))/sqrt(sum(f.^(-2)));
    pink_phases_args(1:simlength/2+1)=rand(1,simlength/2+1)*2*pi-pi;
    pink_phases_args(simlength/2+2:simlength)=-pink_phases_args(2:simlength/2);
    pink_amps(1:simlength/2+1)=f_inv_norm;
    pink_amps(simlength/2+2:simlength)=pink_amps(2:simlength/2);
    pink_hat=exp(sqrt(-1)*pink_phases_args).*pink_amps;
    pink=ifft(pink_hat,'symmetric');
    pink=((pink-mean(pink))*noise_level)/(10*std(pink));
    
    s_noise=low_mode+hi_mode+pink;

    fid1=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_p_noise_',num2str(noise_level),'_rep',num2str(i),'.txt'],'w');
    fprintf(fid1,'%f\n',s_noise);
    fclose(fid1);
    
end