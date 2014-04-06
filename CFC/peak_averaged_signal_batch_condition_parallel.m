function [mean_peak_segments,se_peak_segments]=peak_averaged_signal_batch_condition_parallel(conditions_name,peak_freq,target_freq,no_target_cycles,sampling_freq)

% Finds peaks in trace filtered at frequency peak_freq, spaced at least
% no_target_cycles cycles (at frequency target_freq) apart. Returns all
% segments in a matrix, and locations of peaks in a vector.

segment_length=no_target_cycles*floor(sampling_freq/target_freq);
if mod(segment_length,2) == 0
    segment_length=segment_length+1;
end

t=[1:segment_length]-floor(segment_length/2)-1;
t=t/sampling_freq;

if isempty(conditions_name)

    [conditions_name,conditions_path]=uigetfile('*list','Choose a list of lists to calculate peak-averaged signal.');

else
    
    conditions_path = pwd;
    
end
    
condition_names=textread([conditions_path,conditions_name],'%s');
condition_num=length(condition_names);
list_legend = cell(condition_num,1);

mean_peak_segments=nan(segment_length,condition_num);
se_peak_segments=nan(segment_length,condition_num);

for c=1:condition_num
    
    listname=char(condition_names(c));
    list_legend{c} = listname(1:end-5);
    
    filenames=textread(listname,'%s');
    filenum=length(filenames);
    
    parfor f=1:filenum
        
        filename=char(filenames(f));
        data=load(filename);
        
        [peak_segments,~]=peak_averaged_signal(data,peak_freq,target_freq,no_target_cycles,sampling_freq,0,filename(1:end-4));
        
        no_peaks(f)=size(peak_segments,1);
        
    end
    
%     no_peaks=2*ceil(4096*4/segment_length)*filenum;
    
    All_peak_segments=nan(sum(no_peaks),segment_length);
    
    All_peak_locs=cell(filenum,1);
    
    Aps_index=0;
    
    for f=1:filenum
        
        filename=char(filenames(f));
        
        load([filename(1:end-4),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.mat'])
        
        All_peak_segments(Aps_index+1:Aps_index+size(Peak_segments,1),:)=Peak_segments;
        
        All_peak_locs{f}=Peak_locs;
        
        Aps_index=Aps_index+size(Peak_segments,1);
        
    end
    
    All_peak_segments(Aps_index+1:end,:)=[];
    
    save([listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.mat'],'All_peak_segments','All_peak_locs','peak_freq','target_freq','sampling_freq')
    
    mean_peak_segments(:,c)=mean(All_peak_segments)';
    se_peak_segments(:,c)=std(All_peak_segments)'/sqrt(length(All_peak_segments));
    
    figure()
    plot(t,mean_peak_segments(:,c))
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal for ',listname])
    xlabel('Time From Peak (s)')
    save_as_pdf(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg'])
    
    figure()
    plot(t,se_peak_segments(:,c))
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Signal S.D. for ',listname])
    xlabel('Time From Peak (s)')
    save_as_pdf(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_sd'])
    
    figure()
    boxplot(All_peak_segments)
    title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Signal Boxplot for ',listname])
    set(gca,'XTickLabel',t)
    xlabel('Time From Peak (s)')
    save_as_pdf(gcf,[listname(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_boxplot'])
    
end

save([conditions_path,'/',conditions_name(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg.mat'],'mean_peak_segments','se_peak_segments')

colorset = color_gradient(condition_num,[0 1 1],[1 0 1]);

figure()
set(gca,'ColorOrder',colorset)
hold all
plot(t,mean_peak_segments)
hold on
plot(t,mean_peak_segments+se_peak_segments,':')
plot(t,mean_peak_segments-se_peak_segments,':')
title([num2str(target_freq),' Hz-Spaced ',num2str(peak_freq),' Hz Peak-Triggered Average Signal for ',conditions_name])
xlabel('Time From Peak (s)')
set(gcf,'ColorMap',colorset)
colorbar('YTick',(1:condition_num)+.5,'YTickLabel',list_legend)
save_as_pdf(gcf,[conditions_name(1:end-5),'_',num2str(target_freq),'_spaced_',num2str(peak_freq),'_peak_avg'])