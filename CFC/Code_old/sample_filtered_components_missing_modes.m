whitebg('w')

[raw_filename,raw_pathname]=uigetfile('*rep47.txt','Choose Raw File To Plot');
[list_filename,list_pathname]=uigetfile('*list','Choose List of Raw Files');
fft_pathname=uigetdir('','Choose Directory of FFT files');
[EMD_filename,EMD_pathname]=uigetfile('*rep47.txt.hht','Choose EMD Modes');

dataname=raw_filename(1:end-4);

dirname=[raw_pathname,'Sample_Signal_Figures'];
mkdir (dirname)

data=load([raw_pathname,raw_filename]);
signal_length=length(data);

t=[1:1800]/600;

plot(t,data(1:1800),'k')
box off
set(gca,'XTickLabel','','YTickLabel','')
saveas(gcf,[dirname,'\',raw_filename(1:end-4),'.fig'])

filenames=textread([list_pathname,list_filename],'%s');
filenum=length(filenames);
fft_all=zeros(filenum,signal_length/2);

f=2*600*[1:(signal_length/2)]/signal_length;

figure()

for i=1:filenum
    filename=char(filenames(i));
    filename=filename(1:end-4);
    data_hat=load([fft_pathname,'\',filename,'_fft.txt']);
    data_hat=data_hat(:,2)';
    fft_all(i,:)=data_hat;
    loglog(f(1:floor(signal_length/2)),abs(data_hat(1:floor(signal_length/2))),'k')
    hold on
end
avg_fft=mean(fft_all);
loglog(f(1:floor(signal_length/2)),abs(avg_fft(1:floor(signal_length/2))),'r')
box off 
xlim([.5 900])
set(gca,'XTick',[12.6667 130.6667],'XTickLabel',[6 65],'YTickLabel','')
saveas(gcf,[dirname,'\',list_filename(1:end-5),'_fft.fig'])
hold off

modes=load([EMD_pathname,EMD_filename]);
[no_modes,junk]=size(modes);

H=hilbert(modes');
P=inc_phase(H);
[F,cycle_bounds,bands,cycle_freqs]=cycle_by_cycle_freqs(P,600);

for i=1:length(cycle_bounds)
    nocycles(i)=length(cycle_bounds{i});
end
reliable_modes=find(nocycles>=5);

modes=modes(reliable_modes,:);
no_modes=length(reliable_modes);

ymax=max(max(modes)); ymin=min(min(modes));

axes_positions=zeros(no_modes,4);
axes_positions(:,1)=.1;
axes_spacing=.9/(no_modes);
axes_positions(:,2)=[1-.05-axes_spacing:-axes_spacing:.05]';
axes_positions(:,3)=.85;
axes_positions(:,4)=axes_spacing*.8;

figure()

for i=1:no_modes
    subplot('Position',axes_positions(i,:))
    plot(t,modes(i,1:1800),'k')
    box off
    ylim([ymin ymax])
    ylabel({'Mode';num2str(i)})
    set(gca,'XTickLabel','','YTickLabel','')
end

saveas(gcf,[dirname,'\',dataname,'_EMD.fig'])

sampling_freq=600; spacing='linear'; range_lo=[3 9]; range_hi=[20 110]; nobands=15; buttorders=[-1 3]; pct_pass=1; dirnames={'FFT\He_BW\HAF_Data_Plots';'FFT\Matlab_BW_order_3\HAF_Data\Plots'};

labels={'He';'Mlab'};

for j=1:2
    
    [f,data_hat,bands_lo,low_modes,H_lo,A_lo,P_lo,F_lo,cycle_bounds_lo]=filter_fft_new(data,'fs',sampling_freq,'spacing',spacing,'filename',[dataname,'_lo'],'bandrange',range_lo,'nobands',nobands,'buttorder',buttorders(j),'pct_pass',pct_pass,'dirname',char(dirnames{j}));
    [f,data_hat,bands_hi,hi_modes,H_hi,A_hi,P_hi,F_hi,cycle_bounds_hi]=filter_fft_new(data,'fs',sampling_freq,'spacing',spacing,'filename',[dataname,'_hi'],'bandrange',range_hi,'nobands',nobands,'buttorder',buttorders(j),'pct_pass',pct_pass,'dirname',char(dirnames{j}));

    [junk,no_low_modes]=size(low_modes);
    [junk,no_hi_modes]=size(hi_modes);
    
    figure();
    
    axes_positions=zeros(no_low_modes+no_hi_modes,4);
    axes_positions(:,1)=.1;
    axes_spacing=.9/(no_low_modes+no_hi_modes);
    axes_positions(:,2)=[1-.05-axes_spacing:-axes_spacing:.05]';
    axes_positions(:,3)=.85;
    axes_positions(:,4)=axes_spacing*.8;
    
    for i=1:no_low_modes
        subplot('Position',axes_positions(i,:))
        plot(t,low_modes(1:1800,i),'k')
        box off
%         if j==1
            ylim([-1 1])
%             axes_positions(i,:)=get(h,'Position');
%         end
        ylabel(num2str(bands_lo(i,2)))
        set(gca,'XTickLabel','','YTickLabel','')
    end

    for i=1:no_hi_modes
        subplot('Position',axes_positions(no_low_modes+i,:))
        plot(t,hi_modes(1:1800,i),'k')
        box off
%         if j==1
            ylim([-1 1])
%             axes_positions(no_low_modes+i,:)=get(h,'Position');
%         end
        ylabel(num2str(bands_hi(i,2)))
        set(gca,'XTickLabel','','YTickLabel','')
    end

    saveas(gcf,[dirname,'\',dataname,'_',char(labels{j}),'.fig'])
    
end

[f,data_hat,bands,signals,H,A,P,F,cycle_bounds]=filter_fft_bank(data,sampling_freq,5,10,[1/signal_length sampling_freq/2],2,0,.9,dataname,dirname);

[mode_length,no_modes]=size(signals);

ymax=max(max(signals)); ymin=min(min(signals));

axes_positions=zeros(no_modes,4);
axes_positions(:,1)=.1;
axes_spacing=.9/(no_modes);
axes_positions(:,2)=[1-.05-axes_spacing:-axes_spacing:.05]';
axes_positions(:,3)=.85;
axes_positions(:,4)=axes_spacing*.8;

figure()

for i=1:no_modes
    subplot('Position',axes_positions(i,:))
    plot(t,signals(1:1800,i),'k')
    box off
    ylim([ymin ymax])
    ylabel({'Band';num2str(i)})
    set(gca,'XTickLabel','','YTickLabel','')
end

saveas(gcf,[dirname,'\',dataname,'_Fbank.fig'])