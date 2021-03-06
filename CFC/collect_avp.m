function [P_bands_all,avp_norm_all,avg_AVP]=collect_avp(nobins,noamps,nophases,amps,phases,units)

[listname,listpath]=uigetfile('*list','Choose a list of avp data directories.')

cd (listpath)

dirnames=textread(listname,'%s');
dirnum=length(dirnames);

avp_norm_all=nan(2*nobins,noamps,nophases,dirnum);
A_bands_all=nan(dirnum,noamps);
P_bands_all=nan(dirnum,nophases);

[subplot_rows,subplot_cols]=subplot_size(nophases);
subplot_positions=manual_positions(subplot_rows,subplot_cols);

present_dir=pwd;

for i=1:dirnum

    dirname=char(dirnames(i));
    cd (dirname)
    
    A_bands=load('A_bands.txt');
    A_bands=A_bands(:,2);
    na=length(A_bands);
    A_bands_all(i,1:na)=A_bands';
    for k=1:length(A_bands)
        A_labels{k}=[num2str(A_bands(k),2),' ',units,' Amp.'];
    end
        
    P_bands=load('P_bands.txt');
    P_bands=P_bands(:,2);
    np=length(P_bands);
    P_bands_all(i,1:np)=P_bands';
    
    datanames=textread('avp.list','%s');
    datanum=length(datanames);
    
    for j=1:datanum
        
        dataname=char(datanames(j));
       
        data=load(dataname);
       
        phase_freq=data(1,1);
        amp_freqs=data(1,2:end);
        bin_centers=data(2:end,1);
        avp=data(2:end,2:end);
        [r,c]=size(avp);
        
        avp_norm=avp*diag(1./mean(avp))-ones(size(avp));
        avp_norm=repmat(avp_norm,2,1);
        
        figure()
        colorplot(avp_norm')
        set(gca,'XTick',[1.5:4:2*r+1.5],'XTickLabel',bin_centers(1:4:end)/pi,'YTick',[1.5:c+1.5],'YTickLabel',amp_freqs)
        title(['Amplitude by ',num2str(phase_freq),' for ',dirname(1:end-4)])
        xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
        ylabel(['Frequency (',units,')'])
        saveas(gcf,[dataname(1:end-4),'.fig'])
        close(gcf)
        
        figure()
%         plot(avp_norm(1:j))
        plot(avp_norm(j:end))
        set(gca,'XTick',[1.5:4:2*r+1.5],'XTickLabel',bin_centers(1:4:end)/pi)
        title(['Amplitude by ',num2str(phase_freq),' ',units,' Phase for ',dirname(1:end-4)])
        legend(A_labels{1:j})
        xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
        ylabel(['Frequency (',units,')'])
        saveas(gca,[dataname(1:end-4),'_line.fig'])
        close(gcf)
        
        avp_norm_all(1:2*r,1:c,j,i)=avp_norm;
        
    end
    
    [s_r,s_c]=subplot_size(np);
    s_p=manual_positions(s_r,s_c);
    
    figure()
    for j=1:s_r
        for k=1:s_c
            if s_c*(j-1)+k<=datanum
                subplot('Position',s_p(j,:,k));
                colorplot(avp_norm_all(1:2*r,1:c,s_c*(j-1)+k,i)')
%                 axis xy
%                 caxis([0 max_amp])
%                 colorbar
                title(['Amp. by ',num2str(P_bands(s_c*(j-1)+k)),' ',units,' Phase'])
                if j==s_r
                    set(gca,'XTick',[1.5:5:2*r+1.5],'XTickLabel',bin_centers(1:5:20)/pi)
                else
                    set(gca,'XTick',[])
                end
                if k==1
                    set(gca,'YTick',[1.5:c+1.5],'YTickLabel',amp_freqs(1:end))
                else
                    set(gca,'YTick',[])
                end
            end
        end
    end
    saveas(gcf,[dataname(1:end-5),'_all_avp.fig'])
    
    cd (present_dir)
    
end

avg_A_bands=nanmean(A_bands_all);
for i=1:min(length(avg_A_bands),noamps)
    amp_labels{i}=[num2str(amps(i),2),' (',num2str(avg_A_bands(i),2),') ',units];
end

avg_P_bands=nanmean(P_bands_all);

avg_AVP=nanmean(avp_norm_all,4);
std_AVP=nanstd(avp_norm_all,0,4);
notnan_counts_AVP=sum(~isnan(avp_norm_all),4);
se_AVP=std_AVP./sqrt(notnan_counts_AVP);

format=make_format(nobins*2,'f');

listdir=listname(1:end-5);
mkdir (listdir)
cd (listdir)

for i=1:nophases
    
    fid=fopen([listname(1:end-5),'_p_',num2str(phases(i),2),'_avg_avp.txt'],'w');
    fprintf(fid,format,avg_AVP(:,:,i));
    fclose(fid);
    
    figure()
    colorplot(avg_AVP(:,:,i)')
%     axis xy
    set(gca,'XTick',[1.5:5:2*nobins+1.5],'XTickLabel',bin_centers(1:5:20)/pi,'YTick',[1.5:noamps+1.5],'YTickLabel',amp_labels(1:end))
    title(['Average Amplitude by ',num2str(avg_P_bands(i),2),' ',units,' Phase for ',listname(1:end-4)])
    xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
    ylabel(['Frequency (',units,')'])
    saveas(gca,[listname(1:end-5),'_p_',num2str(avg_P_bands(i),2),'_avg.fig'])
    close(gcf)
       
%     figure()
%     h=plot(avg_AVP(:,1:i,i));
%     hold on
%     plot(avg_AVP(:,1:i,i)+se_AVP(:,1:i,i),':')
%     plot(avg_AVP(:,1:i,i)-se_AVP(:,1:i,i),':')
%     set(gca,'XTick',[1.5:5:2*nobins+1.5],'XTickLabel',bin_centers(1:5:20)/pi)
%     title(['Average Amplitude by ',num2str(avg_P_bands(i),2),' ',units,' Phase for ',listname(1:end-4)])
%     legend(h,amp_labels{1:i})
%     xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
%     ylabel(['Frequency (',units,')'])
%     saveas(gca,[listname(1:end-5),'_p_',num2str(avg_P_bands(i),2),'_avg_line.fig'])
%     close(gcf)

    figure()
    h=plot(avg_AVP(:,i:end,i));
    hold on
    plot(avg_AVP(:,i:end,i)+se_AVP(:,i:end,i),':')
    plot(avg_AVP(:,i:end,i)-se_AVP(:,i:end,i),':')
    set(gca,'XTick',[1.5:5:2*nobins+1.5],'XTickLabel',bin_centers(1:5:20)/pi)
    title(['Average Amplitude by ',num2str(avg_P_bands(i),2),' ',units,' Phase for ',listname(1:end-4)])
    legend(h,amp_labels{i:end})
    xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
    ylabel(['Frequency (',units,')'])
    saveas(gca,[listname(1:end-5),'_p_',num2str(avg_P_bands(i),2),'_avg_line.fig'])
    close(gcf)
    
end

max_amp=nanmax(nanmax(nanmax(avg_AVP(:,1:end-2,1:end-2,:))));

figure()
for j=1:subplot_rows
    for k=1:subplot_cols
        index=subplot_cols*(j-1)+k;
        if index<=nophases
%             subplot('Position',subplot_positions(j,:,k));
            subplot(subplot_rows,subplot_cols,index)
            colorplot(avg_AVP(:,:,index)')
%             axis xy
            caxis([0 max_amp])
            colorbar
            title({['Amp. by ~',num2str(phases(index),2)];['(',num2str(avg_P_bands(index),2),') ',units,' Phase']})
            if j==subplot_rows
                set(gca,'XTick',[1.5:5:2*nobins+1.5],'XTickLabel',bin_centers(1:5:20)/pi)
            else
                set(gca,'XTick',[])
            end
            if k==1
                if c>10
                    set(gca,'YTick',[1.5:2:noamps+1.5],'YTickLabel',amp_labels(1:2:end))

                else
                    set(gca,'YTick',[1.5:noamps+1.5],'YTickLabel',amp_labels)
                end
            else
                set(gca,'YTick',[])
            end
        end
    end
end
saveas(gcf,[listname(1:end-5),'_avg.fig'])

cd (present_dir)

fclose('all')