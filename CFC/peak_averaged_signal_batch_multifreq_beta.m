function mean_peak_segments=peak_averaged_signal_batch_multifreq_beta(peak_freq,target_freq,sampling_freq)

freq_num=length(peak_freq);

if length(target_freq)~=freq_num
    display('peak_freq and target_freq must be vectors of the same length.')
end

freq_label='';
for j=1:freq_num
    freq_labels{j}=[num2str(target_freq(j)),'_spaced_',num2str(peak_freq(j))];
    freq_label=[freq_label,freq_labels{j}];
end
    
[listname,listpath]=uigetfile('*list','Choose a list of files to calculate peak-averaged signal.');

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

max_segment_length=2*floor(sampling_freq/min(target_freq))+1;

t_mat=nan(max_segment_length,freq_num);
mean_peak_segments=nan(max_segment_length,freq_num);
se_peak_segments=nan(max_segment_length,freq_num);

for j=1:freq_num
    
    segment_length=2*floor(sampling_freq/target_freq(j))+1;
    
    peak_freq_wavelet=dftfilt3(peak_freq(j), 8, sampling_freq, 'winsize', segment_length);
    
    t=[1:segment_length]-floor(segment_length/2)-1;
    t=t/sampling_freq;

    fid=fopen([listname(1:end-5),'_',char(freq_labels{j}),'_peak_avg.txt'],'w');

    format=[];
    for i=1:segment_length
        format=[format,'%f\t'];
    end
    format=[format(1:end-1),'n'];

%     Peak_segments=[];
    Peak_segment_sum=zeros(1,segment_length);
    num_peaks=0;

    parfor i=1:filenum
        
        filename=char(filenames(i));
        data=load(filename);
%         signal_length=length(data);

        peak_freq_filtered=conv(data,peak_freq_wavelet);
        %     peak_freq_filtered=peak_freq_filtered(sampling_freq/2+1:end-sampling_freq/2);
        peak_freq_mag=abs(peak_freq_filtered);
        signal_length=length(peak_freq_mag);
        
        Max_locs=zeros(1,signal_length);
        Win_centers=zeros(1,signal_length);

        for k=1:signal_length

            win_center=k;
            win_start=max(1,win_center-floor(segment_length/2));
            win_end=min(signal_length,win_center+floor(segment_length/2));

            [maximum,location]=max(peak_freq_mag(win_start:win_end));
            Maxima(k)=maximum;
            Max_locs(k)=location+win_start-1;
            Win_centers(k)=win_center;

        end

%         peak_freq_filtered=peak_freq_filtered(segment_length+1:end-segment_length);
        peak_freq_mag=peak_freq_mag(segment_length+1:end-segment_length);
        signal_length=length(peak_freq_mag);
        Maxima=Maxima(segment_length+1:end-segment_length);

%         figure(), plot(peak_freq_mag), hold on, plot(real(peak_freq_filtered),'k'), plot(Maxima,'c')

        Peak_locs=Max_locs(Max_locs==Win_centers);

        Peak_locs=Peak_locs-segment_length;
        Peak_locs=Peak_locs(Peak_locs>floor(segment_length/2) & Peak_locs<signal_length-floor(segment_length/2));

%         pfm_max=max(peak_freq_mag);
%         pfm_min=min(peak_freq_mag);

        for k=1:length(Peak_locs)

            num_peaks=num_peaks+1;
            
            peak_location=Peak_locs(k);

%             plot([peak_location peak_location],[pfm_max pfm_min],'r')

            segment_start=max(1,peak_location-floor(segment_length/2));
            segment_end=min(signal_length,peak_location+floor(segment_length/2));
            Peak_segment_sum=Peak_segment_sum+data(segment_start:segment_end)';

            fprintf(fid,format,data(segment_start:segment_end));

        end

%         saveas(gcf,[filename(1:end-4),'_',char(freq_labels{j}),'_peaks.fig'])
%         close(gcf)

    end
    
    Peak_segment_avg=Peak_segment_sum'/num_peaks;
    
    t_mat(1:segment_length,j)=t;
    mean_peak_segments(1:segment_length,j)=Peak_segment_avg;
%     se_peak_segments(1:segment_length,j)=std(Peak_segments)'/sqrt(length(Peak_segments));
    
    fprintf(fid,format,Peak_segment_avg);
    fclose(fid);

%     t=[1:segment_length]-floor(segment_length/2)-1;
%     t=t/sampling_freq;

    figure()
    plot(t,Peak_segment_avg)
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal for ',listname])
    xlabel('Time From Peak (s)')
    saveas(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.fig'])

%     figure()
%     plot(t,std(Peak_segments))
%     title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Signal S.D. for ',listname])
%     xlabel('Time From Peak (s)')
%     saveas(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_sd.fig'])

%     figure()
%     boxplot(Peak_segments)
%     title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Signal Boxplot for ',listname])
%     set(gca,'XTickLabel',t)
%     xlabel('Time From Peak (s)')
%     saveas(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_boxplot.fig'])
    
end

figure()
plot(t_mat,mean_peak_segments)
% hold on
% plot(t_mat,mean_peak_segments+se_peak_segments,':')
% plot(t_mat,mean_peak_segments-se_peak_segments,':')
title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal for ',listname])
xlabel('Time From Peak (s)')
legend(freq_labels)
saveas(gcf,[listname(1:end-5),'_',freq_label,'_peak_avg.fig'])
