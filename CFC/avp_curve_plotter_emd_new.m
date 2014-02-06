function avp_curve_plotter_emd(bincenters,M,figname,dirname,A_labels,P_labels)

Ymax=max(max(max(M)));
[nobins,nomodes,junk]=size(M);

figure();

if nomodes<=10

    for j=1:nomodes
        for k=1:nomodes
            subplot(nomodes,nomodes,nomodes*(k-1)+j);
            Mean=sum(M(:,k,j))/nobins;
            bar(bincenters/pi,M(:,k,j)/Mean,'FaceColor',[0 0 0])
%             plot(bincenters/pi,Mean,'-',bincenters/pi,reshape(M(:,k,j),nobins,1));
%             axis([-1 1 0 Ymax]);
            set(gca,'XTickLabel','','YTickLabel','')
            if mod(nomodes*(k-1)+j,nomodes)==1 & k==nomodes
                set(gca,'XTick',[-1:1],'XTickLabel',{'-1','0','1'},'YTickLabel','')
                if nargin>4
                    xlabel({[P_labels{j},' Hz'];'Phase (\pi)'},'FontSize',14);
                    ylabel({[A_labels{k},' Hz'];'Amplitude'},'FontSize',14);
                else
                    xlabel(['Phase ',num2str(j)]);
                    ylabel(['Amp. ',num2str(k)]);
                end
            elseif mod(nomodes*(k-1)+j,nomodes)==1
                if nargin>4
                    ylabel({[A_labels{k},' Hz'];'Amplitude'},'FontSize',14);
                else
                    ylabel(['Amp. ',num2str(k)]);
                end
            elseif k==nomodes
                set(gca,'XTick',[-1:1],'XTickLabel',{'-1','0','1'},'YTickLabel','')
                if nargin>4
                    xlabel({[P_labels{j},' Hz'];'Phase (\pi)'},'FontSize',14);
                else
                    xlabel(['Phase ',num2str(j),' (\pi)']);
                end
            else
                set(gca,'XTickLabel','','YTickLabel','')
            end
        end
    end
    
    if nargin>3
        if nargin>4
            A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
            P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
            saveas(gcf,[dirname,'\',figname,'_',A_band_labels,'_v_',P_band_labels,'_avp_curves.fig']);
        else
            saveas(gcf,[dirname,'\',figname,'_avp_curves.fig']);
        end
    elseif nargin>2
        saveas(gcf,[figname,'_avp_curves.fig']);
    end
    
elseif nomodes<=100
    
    if nargin>2
        if nargin>3
            if nargin>4
                A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
                P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
                dirname=[dirname,'\',figname,'_',A_band_labels,'_v_',P_band_labels,'_curves'];
            else
                dirname=[dirname,'\',figname,'_avp_curves'];
            end
        else
            dirname=[figname,'_avp_curves'];
        end
        mkdir (dirname);
    end
        
    for j=2:nomodes
        clf();
        cols=ceil(sqrt(j));
        rows=ceil(j/cols);
        for k=1:j-1
            Mean=sum(M(:,k,j))/nobins;
            subplot(rows,cols,k);
            bar(bincenters/pi,M(:,k,j))
%             plot(bincenters/pi,Mean,'-',bincenters/pi,reshape(M(:,k,j),nobins,1));
%             axis([-1 1 0 Ymax]);
            if nargin>4
                xlabel(['Phase of ',P_labels{j},' Component (\pi)']);
                ylabel(['Amp. of ',A_labels{k},' Component']);
            else
                xlabel(['Phase of Component',num2str(j)]);
                ylabel(['Amp. of Component',num2str(k)]);
            end
        end
        if nargin>4
            saveas(gcf,[dirname,'\',figname,'_p_',P_labels{j},'_avp_curves.fig']);
        elseif nargin>2
            saveas(gcf,[dirname,'\',figname,'_p_',num2str(j),'_avp_curves.fig']);
        end
    end
    
    close(gcf);
    
else
    
    if nargin>2
        if nargin>3
            if nargin>4
                A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
                P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
                dirname=[dirname,'\',figname,'_',A_band_labels,'_v_',P_band_labels,'_curves'];
            else
                dirname=[dirname,'\',figname,'_avp_curves'];
            end
        else
            dirname=[figname,'_avp_curves'];
        end
        mkdir (dirname);
    end
        
    for j=1:nomodes
        for k=1:j-1
            Mean=sum(M(:,k,j))/nobins;
            clf;
            bar(bincenters/pi,M(:,k,j))
%             plot(bincenters/pi,Mean,'-',bincenters/pi,reshape(M(:,k,j),nobins,1));
%             axis([-1 1 0 Ymax]);
            if nargin>4
                xlabel(['Phase of ',P_labels{j},' Component (\pi)']);
                ylabel(['Amp. of ',A_labels{k},' Component']);
                if nargin>2
                    saveas(gcf,[dirname,'\',figname,'_a_',A_labels{k},'_v_p_',P_labels{j},'_curve.fig']);
                end
            else
                xlabel(['Phase of Component',num2str(j)]);
                ylabel(['Amp. of Component',num2str(k)]);
                if nargin>2
                    saveas(gcf,[dirname,'\',figname,'_a',num2str(k),'_v_p',num2str(j),'_curve.fig']);
                end
            end
        end
    end
    
    close(gcf);
    
end