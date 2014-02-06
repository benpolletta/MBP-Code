function simulateCFC_random_trend_reps(simlength,sampling_freq,f_lo,f_hi,strength,noise_level,trend_level,noreps)

t=1:simlength;
t=t/sampling_freq;

low_mode=sin(2*pi*f_lo*t);

amp_hi=.5*(strength*low_mode+2-strength);

hi_mode=amp_hi.*sin(2*pi*f_hi*t);

low_cycle_length=sampling_freq/f_lo;
no_low_cycles=simlength/low_cycle_length;

for i=1:noreps
    
    no_kinks=round(trend_level*no_low_cycles);  % no_kinks is some fraction of total 6 Hz cycles.
    slope_max=2*sampling_freq*trend_level/low_cycle_length; % Max. slope is 1 amp. unit per 1/12th of a second.

    kinks=sort(max(round(rand(1,no_kinks)*simlength),1)); % Take no_kinks random numbers between 1 and simlength, sort 'em. 
    kinks=[kinks simlength];
    slopes=2*rand(1,no_kinks+1)*slope_max-slope_max; % Take no_kinks random slopes.
    int=4*rand-2; % Intercept in [-2,2].
    trend(1:kinks(1))=slopes(1)*t(1:kinks(1))+int;
    for j=1:no_kinks
        trend(kinks(j)+1:kinks(j+1))=slopes(j)*(t(kinks(j)+1:kinks(j+1))-t(kinks(j)))+trend(kinks(j));
    end
    
    s=low_mode+hi_mode+trend;

    filename=['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_t_level_',num2str(trend_level),'_rep',num2str(i),'.txt'];
    fid=fopen(filename,'w');
    fprintf(fid,'%f\n',s);

    fid2=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_t_level_',num2str(trend_level),'_rep',num2str(i),'_decomp.txt'],'w');
    fprintf(fid2,'%f\t%f\t%f\t%f\n',[low_mode; amp_hi; hi_mode; trend]);

    fclose('all');

    noise=randn(1,simlength)*noise_level;
    s_noise=s+noise;

    fid1=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_noise_',num2str(noise_level),'_t_level_',num2str(trend_level),'_rep',num2str(i),'.txt'],'w');
    fprintf(fid1,'%f\n',s_noise);
    fclose(fid1);
    
    figno=figure();

    subplot(5,1,2)
%     subplot(3,2,1)
    plot(t,low_mode)
    title('Low-frequency Component')
% 
%     subplot(3,2,2)
%     plot(t,s)
%     title('Signal Without Noise')

    subplot(5,1,3)
%     subplot(3,2,3)
    plot(t,amp_hi,'r',t,hi_mode)
    title('High-frequency Component (Amplitude Envelope in Red)')

    subplot(5,1,5)
%     subplot(3,2,4)
    plot(t,noise)
    title('Noise')

    subplot(5,1,4)
%     subplot(3,2,5)
    plot(t,trend)
    title('Random Trend')

    subplot(5,1,1)
%     subplot(3,2,6)
    plot(s_noise)
    title('Signal With Noise')

    saveas(figno,[filename,'.fig'])
    
    close(figno)
end