function simulateCFC_vary_3rd_osc_reps(simlength,sampling_freq,f_lo,f_hi,f_mid,strength,df_p,da,noise_level,reps)

t=1:simlength;
t=t/sampling_freq;

low_mode=sin(2*pi*f_lo*t);

amp_hi=.5*(strength*low_mode+2-strength);

hi_mode=amp_hi.*sin(2*pi*f_hi*t);


for i=1:reps
    
    index=0;
    last_phase=0;
    while index<simlength
        cycle_amp=randn*da+1;
        cycle_freq=rand*df_p*f_mid+f_mid;
        true_cycle_length=sampling_freq/cycle_freq;
        cycle_length=ceil(sampling_freq/cycle_freq);
        t=2*pi*(0:cycle_length)/true_cycle_length+last_phase;
        mid_mode(index+1:index+cycle_length)=sin(t(1:end-1));
        last_phase=t(end);
        index=index+cycle_length;
    end
    mid_mode=mid_mode(1:simlength);

    s=low_mode+hi_mode+mid_mode;
    
    filename=['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_mid_',num2str(f_mid),'pm',num2str(df_p*f_mid),'_strength_',num2str(strength),'_da_',num2str(da),'_rep_',num2str(i)];

    fid=fopen([filename,'.txt'],'w');
    fid2=fopen([filename,'_decomp.txt'],'w');

    fprintf(fid,'%f\n',s);
    fprintf(fid2,'%f\t%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode; mid_mode]);
    fclose('all');
    
    noise=randn(1,simlength)*noise_level;
    s_noise=s+noise;

    fid1=fopen([filename,'_noise_',num2str(noise_level),'.txt'],'w');
    fprintf(fid1,'%f\n',s_noise);
    fclose(fid1);
end

simulateCFC_plotter(mid_mode,low_mode,amp_hi,hi_mode,s,s_noise,[filename,'_noise_',num2str(noise_level)])
close(gcf)