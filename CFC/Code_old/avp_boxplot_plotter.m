function avp_boxplot_plotter(L,N,figname,dirname,A_labels,P_labels)

Ymax=max(max(max(N)));
[datalength,nomodes_hi,nomodes_lo]=size(N);

figure();

if nomodes_lo<=10 & nomodes_hi<=10

    for j=1:nomodes_lo
        for k=1:nomodes_hi
            subplot(nomodes_hi,nomodes_lo,nomodes_lo*(k-1)+j);
            boxplot(N(:,k,j),L(:,j));
            v=axis;
            axis([v(1) v(2) 0 Ymax]);
            if nargin>4
                xlabel(['Phase of ',P_labels{j},' Component (\pi)']);
                ylabel(['Amp. of ',A_labels{k},' Component']);
            else
                xlabel(['Phase of Component ',num2str(j)]);
                ylabel(['Amp. of Component ',num2str(k)]);
            end
        end
    end
    
    if nargin>3
        if nargin>4
            A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
            P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
            saveas(gcf,[dirname,'\',figname,'_',A_band_labels,'_v_',P_band_labels,'_avp_boxplots.fig']);
        else
            saveas(gcf,[dirname,'\',figname,'_avp_boxplots.fig']);
        end
    elseif nargin>2
        saveas(gcf,[figname,'_avp_boxplots.fig']);
    end
    
elseif nomodes_hi<=100
    
    if nargin>2
        if nargin>3
            if nargin>4
                A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
                P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
                dirname=[dirname,'\',figname,'_',A_band_labels,'_v_',P_band_labels,'_boxplots'];
            else
                dirname=[dirname,'\',figname,'_avp_boxplots'];
            end
        else
            dirname=[figname,'_avp_boxplots'];
        end
        mkdir (dirname);
    end
        
    for j=1:nomodes_lo
        clf();
        for k=1:nomodes_hi
            boxplot(N(:,k,j),L(:,j));
            v=axis;
            axis([v(1) v(2) 0 Ymax]);
            if nargin>4
                xlabel(['Phase of ',P_labels{j},' Component (\pi)']);
                ylabel(['Amp. of ',A_labels{k},' Component']);
            else
                xlabel(['Phase of Component',num2str(j)]);
                ylabel(['Amp. of Component',num2str(k)]);
            end
        end
        if nargin>4
            saveas(gcf,[dirname,'\',figname,'_p_',P_labels{j},'_avp_boxplots.fig']);
        elseif nargin>2
            saveas(gcf,[dirname,'\',figname,'_p_',num2str(j),'_avp_boxplots.fig']);
        end
    end
    
    close(gcf);
    
else
    
    if nargin>2
        if nargin>3
            if nargin>4
                A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
                P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
                dirname=[dirname,'\',figname,'_',A_band_labels,'_v_',P_band_labels,'_boxplots'];
            else
                dirname=[dirname,'\',figname,'_avp_boxplots'];
            end
        else
            dirname=[figname,'_avp_boxplots'];
        end
        mkdir (dirname);
    end
        
    for j=1:nomodes_lo
        for k=1:nomodes_hi
            boxplot(N(:,k,j),L(:,j));
            v=axis;
            axis([v(1) v(2) 0 Ymax]);
            if nargin>4
                xlabel(['Phase of ',P_labels{j},' Component (\pi)']);
                ylabel(['Amp. of ',A_labels{k},' Component']);
                if nargin>2
                    saveas(gcf,[dirname,'\',figname,'_a_',A_labels{k},'_v_p_',P_labels{j},'_boxplot.fig']);
                end
            else
                xlabel(['Phase of Component',num2str(j)]);
                ylabel(['Amp. of Component',num2str(k)]);
                if nargin>2
                    saveas(gcf,[dirname,'\',figname,'_a',num2str(k),'_v_p',num2str(j),'_boxplot.fig']);
                end
            end
        end
    end
    
    close(gcf);
    
end