function simulateCFC_step_reps(length,sampling_freq,f_lo,f_hi,strength,noise_level,height,noreps)

t=1:length;
t=t/sampling_freq;

jump_loc=ceil(rand*length);
step=zeros(1,length);
step(jump_loc:end)=height;

low_mode=sin(2*pi*f_lo*t);

amp_hi=.5*(strength*low_mode+2-strength);

hi_mode=amp_hi.*sin(2*pi*f_hi*t);

s=low_mode+hi_mode+step;

fid=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_step_',num2str(height),'.txt'],'w');
fprintf(fid,'%f\n',s);

fid2=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_step_',num2str(height),'_decomp.txt'],'w');
fprintf(fid2,'%f\t%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode; step]);

fclose('all');

for i=1:noreps
    noise=randn(1,length)*noise_level;
    s_noise=s+noise;

    fid1=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_noise_',num2str(noise_level),'_step_',num2str(height),'_rep',num2str(i),'.txt'],'w');
    fprintf(fid1,'%f\n',s_noise);
    fclose(fid1);
end