function simulateCFC_asym_phase_reps(simlength,sampling_freq,f_lo,f_hi,asym,strength,noise_level,reps)

lo_cycle_length=sampling_freq/f_lo;
lo_cycle_peak=asym*sampling_freq/(2*f_lo);
lo_cycle_trough=(sampling_freq/f_lo)*(1-asym/2);

t=1:simlength;
t_mod=mod(t,lo_cycle_length);
rising=find(t_mod<=lo_cycle_peak | lo_cycle_trough<t_mod);
falling=find(lo_cycle_peak<t_mod & t_mod<=lo_cycle_trough);
phase_diff(rising)=pi/(2*lo_cycle_peak);
phase_diff(falling)=pi/(lo_cycle_trough-lo_cycle_peak);

phase_lo=cumsum(phase_diff);
low_mode=sin(phase_lo);

amp_env=.5*(low_mode+1);
amp_hi=strength*amp_env+1-strength;

hi_mode=sin(t/sampling_freq*f_hi*2*pi);
hi_mode=amp_hi.*hi_mode;

s=low_mode+hi_mode;

filename=['simCFC_a_',num2str(f_lo),'_p_',num2str(f_hi),'_asym_',num2str(asym),'_strength_',num2str(strength)];

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