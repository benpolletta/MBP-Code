function avp_curve_plotter_Jan(bincenters,M,figname,bands_hi,bands_lo,units)

present_dir=pwd;

Ymax=max(max(max(M)));
[nobins,nomodes_hi,nomodes_lo]=size(M);
M_norm=zeros(size(M));

figure();

for j=1:nomodes_lo
    P_labels{j}=[num2str(bands_lo(j),3),'-',char(units)];
    for k=1:nomodes_hi
        if j==1
            A_labels{k}=[num2str(bands_hi(k),3),'-',char(units)];
        end
        Mean=sum(M(:,k,j))/nobins;
        M_norm(:,k,j)=M(:,k,j)/Mean;
        plot(bincenters/pi+3*(j-1),M_norm(:,k,j)+k-2);
%         plot(bincenters/pi+3*(j-1),M(:,k,j)+k-2);
        hold on;
    end
end

if nargin>3
    set(gca,'XTick',[0:3:3*nomodes_lo-1],'XTickLabel',P_labels)
    set(gca,'YTick',[0:nomodes_hi-1],'YTickLabel',A_labels)
else
    set(gca,'XTick',[0:3:3*nomodes_lo-1],'XTickLabel',[1:nomodes_lo])
    set(gca,'YTick',[0:nomodes_hi-1],'YTickLabel',[1:nomodes_hi])
end

title('Mean Amplitude by Phase Bin')
xlabel('Phase-Giving Freq. (Hz)')
ylabel('Amp.-Giving Freq. (Hz)')
xlim([-3,3*nomodes_lo])
ylim([-1,nomodes_hi])

if nargin>2
    saveas(gcf,[figname,'_avp.fig']);
end

% M_mat=nan(nobins,nomodes_hi+1,nomodes_lo);
% M_mat(1:nobins,1:nomodes_hi,1:nomodes_lo)=M;
% M_mat=reshape(M_mat,nobins,(nomodes_hi+1)*nomodes_lo);
% M_mat=repmat(M_mat,[2 1]);
% 
% figure();
% 
% colorplot(M_mat')
% caxis([min(min(M_mat)),max(max(M_mat))])
% 
% % if nargin>3
% %     set(gca,'XTick',[1.5:nomodes_lo+1.5],'XTickLabel',P_labels)
% %     set(gca,'YTick',[1.5:nomodes_hi+1.5],'YTickLabel',A_labels)
% % else
% %     set(gca,'XTick',[0:3:3*nomodes_lo-1],'XTickLabel',[1:nomodes_lo])
% %     set(gca,'YTick',[0:nomodes_hi-1],'YTickLabel',[1:nomodes_hi])
% % end
% 
% title('Mean Amplitude by Phase Bin')
% xlabel('Phase-Giving Freq.')
% ylabel('Amp.-Giving Freq.')
% 
% if nargin>2
%     saveas(gcf,[figname,'_avp_colorplot.fig']);
% end

M_mat=M_norm-ones(size(M));
M_mat=repmat(M_mat,[2 1 1]);
M_min=min(min(min(M_mat)));
M_max=max(max(max(M_mat)));

[s_r,s_c]=subplot_size(nomodes_lo);

figure()

for j=1:s_r
    for k=1:s_c
        if s_c*(j-1)+k<=nomodes_lo
            %             subplot('Position',s_p(j,:,k));
            subplot(s_r,s_c,s_c*(j-1)+k)
            colorplot_no_colorbar(M_mat(:,:,s_c*(j-1)+k)')
            axis xy
            if M_min<M_max
                caxis([M_min M_max])
            end
            title(['Amp. by ',char(P_labels(s_c*(j-1)+k)),' Phase'])
            if j==s_r
                set(gca,'XTick',[1.5:5:2*nobins+1.5],'XTickLabel',bincenters(1:5:20)/pi)
            else
                set(gca,'XTick',[])
            end
            if k==1
                set(gca,'YTick',[1.5:nomodes_hi+1.5],'YTickLabel',A_labels)
            elseif k==s_c
                colorbar
            else
                set(gca,'YTick',[])
            end
        end
    end
end

saveas(gcf,[figname,'_avp_colorplot.fig'])
close(gcf)
% 
% M_mat=M-ones(size(M));
% M_mat=repmat(M_mat,[2 1 1]);
% 
% [s_r,s_c]=subplot_size(nomodes_lo);

for l=1:nomodes_lo

    figure()
    
    imagesc(M_mat(:,:,l)')
    axis xy
    colorbar
    
    title(['Amp. by ',char(P_labels(l)),' Phase'])
    set(gca,'XTick',[1.5:5:2*nobins+1.5],'XTickLabel',bincenters(1:5:20)/pi)
    set(gca,'YTick',[1.5:nomodes_hi+1.5],'YTickLabel',A_labels)
    
    saveas(gcf,[figname,'_p_',char(P_labels(l)),'_avp.fig'])
    close(gcf)
        
end