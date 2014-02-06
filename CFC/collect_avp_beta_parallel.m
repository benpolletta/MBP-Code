function avp_norm_avg=collect_avp_beta_parallel(nobins,noamps,nophases,amps,phases,units)

[listname,listpath]=uigetfile('*list','Choose a list of avp data directories.');

cd (listpath)

dirnames=textread(listname,'%s');
dirnum=length(dirnames);

bin_centers=-.95:.1:.95;
bin_centers_long=repmat(bin_centers,1,2);

avp_norm_avg=zeros(2*nobins,noamps,nophases);
A_bands_avg=zeros(noamps,1);
P_bands_avg=zeros(nophases,1);

[subplot_rows,subplot_cols]=subplot_size(nophases);
% subplot_positions=manual_positions(subplot_rows,subplot_cols);

present_dir=pwd;

parfor i=1:dirnum
    
%     pack

    dirname=char(dirnames(i));
    cd (dirname)
    
    A_bands=load('A_bands.txt');
    A_bands=A_bands(:,2);
%     na=length(A_bands);
%     A_bands_avg(1:na)=nansum([A_bands_avg(1:na) A_bands'/dirnum],2);
    A_bands_avg=A_bands_avg+A_bands/dirnum;
%     for k=1:length(A_bands)
%         A_labels{k}=[num2str(A_bands(k),2),' ',units,' Amp.'];
%     end
        
    P_bands=load('P_bands.txt');
    P_bands=P_bands(:,2);
%     np=length(P_bands);
%     P_bands_avg(1:np)=nansum([P_bands_avg(1:np) P_bands'/dirnum],2);
    P_bands_avg=P_bands_avg+P_bands/dirnum;

    phasenames=textread('avp.list','%s');
    phasenum=length(phasenames);
    
    avp_array=zeros(2*nobins,noamps,nophases);
    
    for j=1:phasenum
        
        phasename=char(phasenames(j));
       
        data=load(phasename);
       
%         phase_freq=data(1,1);
%         amp_freqs=data(1,2:end);
%         bin_centers=data(2:end,1);
        avp=data(2:end,2:end);
%         [r,c]=size(avp);
        
        avp_norm=avp*diag(1./mean(avp))-ones(size(avp));
        avp_array(:,:,j)=repmat(avp_norm,2,1);
        
%         figure()
%         colorplot(avp_norm')
%         set(gca,'XTick',[1.5:4:2*r+1.5],'XTickLabel',bin_centers(1:4:end)/pi,'YTick',[1.5:c+1.5],'YTickLabel',amp_freqs)
%         title(['Amplitude by ',num2str(phase_freq),' for ',dirname(1:end-4)])
%         xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
%         ylabel(['Frequency (',units,')'])
%         saveas(gcf,[phasename(1:end-4),'.fig'])
%         close(gcf)
%         
%         figure()
% %         plot(avp_norm(1:j))
%         plot(avp_norm(j:end))
%         set(gca,'XTick',[1.5:4:2*r+1.5],'XTickLabel',bin_centers(1:4:end)/pi)
%         title(['Amplitude by ',num2str(phase_freq),' ',units,' Phase for ',dirname(1:end-4)])
%         legend(A_labels{1:j})
%         xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
%         ylabel(['Frequency (',units,')'])
%         saveas(gca,[phasename(1:end-4),'_line.fig'])
%         close(gcf)
        
%         temp=nan(2*r,c,2);
%         temp(:,:,1)=avp_norm_avg(1:2*r,1:c,j);
%         temp(:,:,2)=avp_norm/dirnum;
%         avp_norm_avg(1:2*r,1:c,j)=nansum(temp,3);
        
    end
    
    avp_norm_avg=avp_norm_avg+avp_array/dirnum;
    
%     [s_r,s_c]=subplot_size(np);
% %     s_p=manual_positions(s_r,s_c);
% 
%     max_avp=nanmax(nanmax(nanmax(avp_norm)));
%     min_avp=nanmin(nanmin(nanmin(avp_norm)));
% 
%     figure()
%     for j=1:s_r
%         for k=1:s_c
%             if s_c*(j-1)+k<=phasenum
%                 subplot(s_r,s_c,s_c*(j-1)+k)
% %                 subplot('Position',s_p(j,:,k));
%                 colorplot_no_colorbar(avp_norm_avg(1:2*r,1:c,s_c*(j-1)+k)')
%                 axis xy
%                 caxis([min_avp max_avp])
% %                 colorbar
%                 title(['Amp. by ',num2str(P_bands(s_c*(j-1)+k)),' ',units,' Phase'])
%                 if j==s_r
%                     set(gca,'XTick',[1.5:5:2*r+1.5],'XTickLabel',bin_centers(1:5:20)/pi)
%                 else
%                     set(gca,'XTick',[])
%                 end
%                 if k==1
%                     set(gca,'YTick',[1.5:c+1.5],'YTickLabel',amp_freqs(1:end))
%                 elseif k==s_c
%                     colorbar
%                 else
%                     set(gca,'YTick',[])
%                 end
%             end
%         end
%     end
%     saveas(gcf,[phasename(1:end-5),'_all_avp.fig'])
%     close(gcf)
    
    cd (present_dir)
    
end

for i=1:min(length(A_bands_avg),noamps)
    amp_labels{i}=[num2str(amps(i),3),' (',num2str(A_bands_avg(i),3),') ',units];
end

% P_bands_avg=nanmean(P_bands_all);

format=make_format(nobins*2,'f');

listdir=listname(1:end-5);
mkdir (listdir)
cd (listdir)

for i=1:nophases
    
    fid=fopen([listname(1:end-5),'_p_',num2str(phases(i),3),'_avg_avp.txt'],'w');
    fprintf(fid,format,avp_norm_avg(:,:,i));
    fclose(fid);
    
    figure()
    colorplot(avp_norm_avg(:,:,i)')
%     axis xy
    set(gca,'XTick',[1.5:3:2*nobins+1.5],'XTickLabel',bin_centers_long(1:3:40),'YTick',[1.5:noamps+1.5],'YTickLabel',amp_labels(1:end))
    title(['Average Amplitude by ',num2str(P_bands_avg(i),2),' ',units,' Phase for ',listname(1:end-4)])
    xlabel([num2str(phases(i)),' ',units,' Phase (\pi)'])
    ylabel(['Frequency (',units,')'])
    saveas(gca,[listname(1:end-5),'_p_',num2str(P_bands_avg(i),2),'_avg.fig'])
    close(gcf)
       
%     figure()
%     h=plot(avp_norm_avg(:,1:i,i));
%     hold on
%     plot(avp_norm_avg(:,1:i,i)+se_AVP(:,1:i,i),':')
%     plot(avp_norm_avg(:,1:i,i)-se_AVP(:,1:i,i),':')
%     set(gca,'XTick',[1.5:5:2*nobins+1.5],'XTickLabel',bin_centers(1:5:20)/pi)
%     title(['Average Amplitude by ',num2str(P_bands_avg(i),2),' ',units,' Phase for ',listname(1:end-4)])
%     legend(h,amp_labels{1:i})
%     xlabel([num2str(phase_freq),' ',units,' Phase (\pi)'])
%     ylabel(['Frequency (',units,')'])
%     saveas(gca,[listname(1:end-5),'_p_',num2str(P_bands_avg(i),2),'_avg_line.fig'])
%     close(gcf)

    figure()
    h=plot(avp_norm_avg(:,i:end,i));
    set(gca,'XTick',[1.5:3:2*nobins+1.5],'XTickLabel',bin_centers_long(1:3:40))
    title(['Average Amplitude by ',num2str(P_bands_avg(i),2),' ',units,' Phase for ',listname(1:end-4)])
    legend(h,amp_labels{i:end})
    xlabel([num2str(phases(i)),' ',units,' Phase (\pi)'])
    ylabel(['Frequency (',units,')'])
    saveas(gca,[listname(1:end-5),'_p_',num2str(P_bands_avg(i),2),'_avg_line.fig'])
    close(gcf)
    
end

max_amp=max(max(max(avp_norm_avg)));
min_amp=min(min(min(avp_norm_avg)));

figure()
for j=1:subplot_rows
    for k=1:subplot_cols
        index=subplot_cols*(j-1)+k;
        if index<=nophases
%             subplot('Position',subplot_positions(j,:,k));
            subplot(subplot_rows,subplot_cols,index)
            colorplot_no_colorbar(avp_norm_avg(:,:,index)')
            caxis([min_amp max_amp])
            axis xy
            title({['Amp. by ~',num2str(phases(index),2)];['(',num2str(P_bands_avg(index),2),') ',units,' Phase']})
            if j==subplot_rows
                set(gca,'XTick',[1.5:3:2*nobins+1.5],'XTickLabel',bin_centers_long(1:3:40))
            else
                set(gca,'XTick',[])
            end
            if k==1
                if noamps>10
                    set(gca,'YTick',[1.5:2:noamps+1.5],'YTickLabel',amp_labels(1:2:end))
                else
                    set(gca,'YTick',[1.5:noamps+1.5],'YTickLabel',amp_labels)
                end
            elseif k==subplot_cols
                colorbar
%                 caxis([min_amp max_amp])
            else
                set(gca,'YTick',[])
            end
        end
    end
end
saveas(gcf,[listname(1:end-5),'_avg.fig'])

cd (present_dir)

fclose('all')