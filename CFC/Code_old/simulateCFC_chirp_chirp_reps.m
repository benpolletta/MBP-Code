function simulateCFC_chirp_chirp_reps(simlength,sampling_freq,f_lo_int,f_hi_int,strength,noise_level,reps)

f_lo=diff(f_lo_int)*[1:simlength]/simlength+f_lo_int(1);
phase_diff_lo=2*pi*f_lo./sampling_freq;
phase_lo=cumsum(phase_diff_lo);
low_mode=sin(phase_lo);

f_hi=diff(f_hi_int)*[1:simlength]/simlength+f_hi_int(1);
phase_diff_hi=2*pi*f_hi./sampling_freq;
phase_hi=cumsum(phase_diff_hi);
hi_mode=sin(phase_hi);

amp_env=.5*(low_mode+1);
amp_hi=strength*amp_env+1-strength;

hi_mode=amp_hi.*hi_mode;

s=low_mode+hi_mode;

filename=['simCFC_a_',num2str(f_lo_int(1)),'-',num2str(f_lo_int(2)),'_p_',num2str(f_hi_int(1)),'-',num2str(f_hi_int(2)),'_strength_',num2str(strength)];

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