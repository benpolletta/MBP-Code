function avp_plotter(M,figname,A_bands,P_bands)

Ymax=max(max(max(M)));

figure();

if nomodes_lo<=10 & nomodes_hi<=10

    for j=1:nomodes_lo
        for k=1:nomodes_hi
            subplot(nomodes_hi,nomodes_lo,nomodes_lo*(k-1)+j);
            Mean=sum(M(:,j,k))/nobins;
            clf;
            plot(bincenters/pi,Mean,'-',bincenters/pi,M(:,j,k));
            axis([-1 1 0 Ymax]);
            if nargin>5
                xlabel(['Phase of ',num2str(P_bands(j,1)),' to ',num2str(P_bands(j,3)),' Band (\pi)']);
                ylabel(['Amp. of ',num2str(A_bands(k,1)),' to ',num2str(A_bands(k,3)),' Band']);
            else
                xlabel(['Phase of Mode',num2str(j)]);
                ylabel(['Amp. of Mode',num2str(k)]);
            end
        end
    end
    if nargin>4
        saveas(gcf,[figname,'_avp_binned.fig']);
    end
    
else

    for j=1:nomodes_lo
        for k=1:nomodes_hi
            Mean=sum(M(:,j,k))/nobins;
            clf;
            plot(bincenters/pi,Mean,'-',bincenters/pi,M(:,j,k));
            axis([-1 1 0 Ymax]);
            if nargin>5
                xlabel(['Phase of ',num2str(P_bands(j,1)),' to ',num2str(P_bands(j,3)),' Band (\pi)']);
                ylabel(['Amp. of ',num2str(A_bands(k,1)),' to ',num2str(A_bands(k,3)),' Band']); 
                if nargin>4
                    saveas(gcf,[figname,'_a_',num2str(A_bands(k,1)),' to ',num2str(A_bands(k,3)),'_v_p_',num2str(P_bands(j,1)),' to ',num2str(P_bands(j,3)),'.fig']);
                end
            else
                xlabel(['Phase of Mode',num2str(j)]);
                ylabel(['Amp. of Mode',num2str(k)]);
                if nargin>4
                    saveas(gcf,[figname,'_a',num2str(k),'_v_p',num2str(j),'.fig']);
                end
            end
        end
    end
    
    close(gcf);
    
end