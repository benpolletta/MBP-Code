function [mean_peak_segments,se_peak_segments]=peak_averaged_signal_batch_condition(peak_freq,target_freq,no_target_cycles,sampling_freq,epoch_length)

segment_length=no_target_cycles*floor(sampling_freq/target_freq)+1;

max_segments=2*ceil(epoch_length/segment_length);

t=[1:segment_length]-floor(segment_length/2)-1;
t=t/sampling_freq;

format=make_format(segment_length,'f');
    
peak_freq_wavelet=dftfilt3(peak_freq, 7, sampling_freq, 'winsize', segment_length);

[conditions_name,conditions_path]=uigetfile('*list','Choose a list of lists to calculate peak-averaged signal.');

condition_names=textread([conditions_path,conditions_name],'%s');
condition_num=length(condition_names);

mean_peak_segments=nan(segment_length,condition_num);
se_peak_segments=nan(segment_length,condition_num);

for j=1:condition_num
    
    listname=char(condition_names(j));

    filenames=textread(listname,'%s');
    filenum=length(filenames);

    fid=fopen([listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.txt'],'w');

    Peak_segments=nan(max_segments*filenum,segment_length);

    for f=1:filenum

        filename=char(filenames(f));
        data=load(filename);
        signal_length=length(data);
        
        Maxima=nan(1,signal_length);
        Max_locs=nan(1,signal_length);
        Win_centers=nan(1,signal_length);
        
        peak_freq_filtered=conv(data,peak_freq_wavelet);
        %     peak_freq_filtered=peak_freq_filtered(sampling_freq/2+1:end-sampling_freq/2);
        peak_freq_mag=abs(peak_freq_filtered);
        signal_length=length(peak_freq_mag);

        for i=1:signal_length

            win_center=i;
            win_start=max(1,win_center-floor(segment_length/2));
            win_end=min(signal_length,win_center+floor(segment_length/2));

            [maximum,location]=max(peak_freq_mag(win_start:win_end));
            Maxima(i)=maximum;
            Max_locs(i)=location+win_start-1;
            Win_centers(i)=win_center;

        end

        peak_freq_filtered=peak_freq_filtered(segment_length+1:end-segment_length);
        peak_freq_mag=peak_freq_mag(segment_length+1:end-segment_length);
        signal_length=length(peak_freq_mag);
        Maxima=Maxima(segment_length+1:end-segment_length);

        figure(), plot(peak_freq_mag), hold on, plot(real(peak_freq_filtered),'k'), plot(Maxima,'c')

        Peak_locs=Max_locs(Max_locs==Win_centers);

        Peak_locs=Peak_locs-segment_length;
        Peak_locs=Peak_locs(Peak_locs>floor(segment_length/2) & Peak_locs<signal_length-floor(segment_length/2));

        pfm_max=max(peak_freq_mag);
        pfm_min=min(peak_freq_mag);

        for i=1:length(Peak_locs)

            peak_location=Peak_locs(i);

            plot([peak_location peak_location],[pfm_max pfm_min],'r')

            segment_start=max(1,peak_location-floor(segment_length/2));
            segment_end=min(signal_length,peak_location+floor(segment_length/2));
            Peak_segments(i,:)=data(segment_start:segment_end)';

            fprintf(fid,format,data(segment_start:segment_end));

        end

        saveas(gcf,[filename(1:end-4),'_peaks.fig'])
        close(gcf)

    end
    
    mean_peak_segments(:,j)=mean(Peak_segments)';
    se_peak_segments(:,j)=std(Peak_segments)'/sqrt(length(Peak_segments));
    
    fprintf(fid,format,mean(Peak_segments));
    fclose(fid);

%     t=[1:segment_length]-floor(segment_length/2)-1;
%     t=t/sampling_freq;

    figure()
    plot(t,mean(Peak_segments))
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal for ',listname])
    xlabel('Time From Peak (s)')
    saveas(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.fig'])

    figure()
    plot(t,std(Peak_segments))
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Signal S.D. for ',listname])
    xlabel('Time From Peak (s)')
    saveas(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_sd.fig'])

    figure()
    boxplot(Peak_segments)
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Signal Boxplot for ',listname])
    set(gca,'XTickLabel',t)
    xlabel('Time From Peak (s)')
    saveas(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_boxplot.fig'])
    
end

figure()
plot(t,mean_peak_segments)
hold on
plot(t,mean_peak_segments+se_peak_segments,':')
plot(t,mean_peak_segments-se_peak_segments,':')
title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal for ',listname])
xlabel('Time From Peak (s)')
legend(condition_names)
saveas(gcf,[conditions_name(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.fig'])
