function [noise,low_mode,amp_hi,hi_mode,s,s_noise]=simulateCFC_varying_amp_phase(length,sampling_freq,f_lo,f_hi,strength,df_lo,df_hi,da,noise_level)

noise=randn(1,length)*noise_level;

t=1:(length*sampling_freq);
t=t/sampling_freq;

index=0;
while index<length
    cycle_amp=rand*da+1-da/2;
    cycle_freq=rand*df_lo+f_lo-df_lo/2;
    cycle_length=floor(sampling_freq/cycle_freq);
    t=2*pi*(1:cycle_length)/cycle_length;
    low_mode(index+1:index+cycle_length)=cycle_amp*sin(t);
    index=index+cycle_length;
end
low_mode=low_mode(1:length);

index=0;
while index<length
    cycle_amp=rand*da+1-da/2;
    cycle_freq=rand*df_hi+f_hi-df_hi/2;
    cycle_length=floor(sampling_freq/cycle_freq);
    t=2*pi*(1:cycle_length)/cycle_length;
    hi_mode(index+1:index+cycle_length)=cycle_amp*sin(t);
    index=index+cycle_length;
end
hi_mode=hi_mode(1:length);

amp_env=.5*(low_mode-min(low_mode));
amp_hi=strength*amp_env+1-strength;

hi_mode=amp_hi.*hi_mode;

s=low_mode+hi_mode;

s_noise=low_mode+hi_mode+noise;

fid=fopen(['simCFC_a_',num2str(f_hi),'pm',num2str(df_hi),'_p_',num2str(f_lo),'pm',num2str(df_lo),'_strength_',num2str(strength),'_da_',num2str(da),'.txt'],'w');
fid1=fopen(['simCFC_a_',num2str(f_hi),'pm',num2str(df_hi),'_p_',num2str(f_lo),'pm',num2str(df_lo),'_strength_',num2str(strength),'_da_',num2str(da),'_noise_',num2str(noise_level),'.txt'],'w');
fid2=fopen(['simCFC_a_',num2str(f_hi),'pm',num2str(df_hi),'_p_',num2str(f_lo),'pm',num2str(df_lo),'_strength_',num2str(strength),'_da_',num2str(da),'_noise_',num2str(noise_level),'_decomp.txt'],'w');

fprintf(fid,'%f\n',s);
fprintf(fid1,'%f\n',s_noise);
fprintf(fid2,'%f\t%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode; noise]);