function simulateCFC_varying_amp_reps(simlength,sampling_freq,f_lo,f_hi,strength,da,noise_level,reps)

index=1:simlength;
t=index/sampling_freq;

low_mode=sin(2*pi*f_lo*t);
low_cycle_length=sampling_freq/f_lo;
for i=1:ceil(simlength/low_cycle_length)
    cycle_amp=rand*da+1-da/2;
    low_amp(low_cycle_length*(i-1)<index & index<=low_cycle_length*i)=cycle_amp;
end
low_mode=low_mode.*low_amp;

amp_env=.5*(low_mode-min(low_mode));
amp_hi=strength*amp_env+1-strength;

hi_mode=amp_hi.*sin(2*pi*f_hi*t);

s=low_mode+hi_mode;

filename=['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_da_',num2str(da),'_strength_',num2str(strength)];

fid=fopen([filename,'txt'],'w');
fid2=fopen([filename,'_decomp.txt'],'w');

fprintf(fid,'%f\n',s);
fprintf(fid2,'%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode]);
fclose('all');

noise=zeros(1,simlength);
s_noise=s;
for i=1:reps
    noise=randn(1,simlength)*noise_level;
    s_noise=s+noise;

    fid1=fopen([filename,'_noise_',num2str(noise_level),'_rep',num2str(i),'.txt'],'w');
    fprintf(fid1,'%f\n',s_noise);
    fclose(fid1);
end

simulateCFC_plotter(noise,low_mode,amp_hi,hi_mode,s,s_noise,[filename,'_noise_',num2str(noise_level)])
close(gcf)