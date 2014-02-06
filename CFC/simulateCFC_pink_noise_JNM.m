function simulateCFC_pink_noise_JNM(noise_level)

noreps=50;
simlength=1800;
sampling_freq=600;
f_lo=6; 
f_hi=65;
strength=.75;

t=1:simlength;
t=t/sampling_freq;

f=sampling_freq*[0:simlength/2]/simlength;

f_inv=f.^(-1);
f_inv=[f_inv fliplr(f_inv(2:end-1))];
f_inv_norm=f_inv/sqrt(sum(f_inv(2:end).^2)+1);
f_inv_norm(1)=1;

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

    noise=randn(1,simlength)*noise_level;
    
    s_noise=s+noise;
   
    s_noise_hat=fft(s_noise).*f_inv_norm;

    s_noise=real(ifft(s_noise_hat,'symmetric'));
    s_noise=s_noise-mean(s_noise);

%     figure(); plot(s_noise);
    
    fid1=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_p_noise_',num2str(noise_level),'_rep',num2str(i),'.txt'],'w');
    fprintf(fid1,'%f\n',s_noise);
    fclose(fid1);
    
end