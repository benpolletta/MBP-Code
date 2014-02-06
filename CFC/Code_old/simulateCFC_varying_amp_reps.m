function simulateCFC_varying_amp_reps(simlength,sampling_freq,f_lo,f_hi,df_hi,da,strength,noise_level,reps)

for i=1:reps
    
    t=[1:simlength]/sampling_freq;
    low_mode=sin(2*pi*f_lo*t);
    
    index=0;
    last_phase=0;
    while index<simlength
        cycle_amp=rand*da+1-da/2;
        cycle_freq=rand*df_hi+f_hi-df_hi/2;
        true_cycle_length=sampling_freq/cycle_freq;
        cycle_length=ceil(sampling_freq/cycle_freq);
        t=2*pi*(0:cycle_length)/true_cycle_length+last_phase;
        hi_mode(index+1:index+cycle_length)=cycle_amp*sin(t(1:end-1));
        last_phase=t(end);
        index=index+cycle_length;
    end
    hi_mode=hi_mode(1:simlength);

    amp_env=.5*(low_mode+1);
    amp_hi=strength*amp_env+1-strength;

    hi_mode=amp_hi.*hi_mode;

    s=low_mode+hi_mode;
    
    noise=randn(1,simlength)*noise_level;
    
    s_noise=s+noise;

    filename=['simCFC_a_',num2str(f_hi),'pm',num2str(df_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_da_',num2str(da),'_rep',num2str(i)];

    fid=fopen([filename,'_decomp.txt'],'w');
    fid1=fopen([filename,'.txt'],'w');

    fprintf(fid,'%f\t%f\t%f\t%f\t%f\n',[noise; low_mode; amp_hi; hi_mode; s]);
    fprintf(fid1,'%f\n',s_noise);
    fclose('all');
    
    simulateCFC_plotter(noise,low_mode,amp_hi,hi_mode,s,s_noise,filename)
    close(gcf)
    
end

