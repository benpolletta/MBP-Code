function simulateCFC_width(length,sampling_freq,f_lo,f_hi,strength,width,noise_level,noreps)

t=1:length;
t=t/sampling_freq;

low_t=2*pi*f_lo*t;
low_mode=sin(low_t);
% triwave=(2*pi-max(mod(2*low_t,2*pi),2*pi-mod(2*low_t,2*pi)))/pi;
% amp_env=(normpdf(triwave,0,width)-normpdf(1,0,width))/(normpdf(0,0,width)-normpdf(1,0,width))
amp_env=(normpdf(low_mode,0,width)-normpdf(1,0,width))/(normpdf(0,0,width)-normpdf(1,0,width));

amp_hi=strength*amp_env+1-strength;

hi_mode=amp_hi.*sin(2*pi*f_hi*t);

s=low_mode+hi_mode;

fid=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_width_',num2str(width),'_rep',num2str(i),'.txt'],'w');

fprintf(fid,'%f\n',s);

for i=1:noreps

    noise=randn(1,length)*noise_level;

    s_noise=s+noise;

    fid1=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_width_',num2str(width),'_noise_',num2str(noise_level),'_rep',num2str(i),'.txt'],'w');
    fid2=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_width_',num2str(width),'_noise_',num2str(noise_level),'_rep',num2str(i),'_decomp.txt'],'w');

    fprintf(fid1,'%f\n',s_noise);
    fprintf(fid2,'%f\t%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode; noise]);

end