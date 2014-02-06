function avp_curve_plotter(bincenters,M,figname,A_labels,P_labels)

present_dir=pwd;

Ymax=max(max(max(M)));
[nobins,nomodes_hi,nomodes_lo]=size(M);

figure();

if nomodes_lo<=10 & nomodes_hi<=10

    for j=1:nomodes_lo
        for k=1:nomodes_hi
            subplot(nomodes_hi,nomodes_lo,nomodes_lo*(k-1)+j);
            Mean=sum(M(:,k,j))/nobins;
            plot(bincenters/pi,Mean,'-',bincenters/pi,M(:,k,j));
%             axis([-1 1 0 Ymax]);
            if nargin>3
                if j==1
                    ylabel([A_labels{k},' Amp.']);
                elseif k==nomodes_hi
                    xlabel([P_labels{j},' Phase (\pi)']);
                end
            else
                if j==1
                    ylabel(['Amp. ',num2str(k)]);
                elseif k==nomodes_hi
                    xlabel(['Phase ',num2str(j)]);
                end
            end
        end
    end

    if nargin>4 
        A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
        P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
%         if length([figname,'_',A_band_labels,'_v_',P_band_labels,'_avp.fig'])<=namelengthmax
            saveas(gcf,[figname,'_',A_band_labels,'_v_',P_band_labels,'_avp.fig']);
%         elseif length([figname,'_avp.fig'])<=namelengthmax
%             saveas(gcf,[figname,'_avp.fig']);
%         else
%             saveas(gcf,[figname(end-namelengthmax+8:end),'_avp.fig'])
%         end
    else
%         if length([figname,'_avp.fig'])<=namelengthmax
            saveas(gcf,[figname,'_avp.fig']);
%         else
%             saveas(gcf,[figname(1:24),'_avp.fig']);
%         end
    end
    
elseif nomodes_hi<=100

    if nargin>3
        A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
        P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
%         if length([figname,'_',A_band_labels,'_v_',P_band_labels])<=namelengthmax
            dirname=[figname,'_',A_band_labels,'_v_',P_band_labels];
%         elseif length([figname,'_avp'])<=namelengthmax
%             dirname=[figname,'_avp'];
%         else
%             dirname=[figname(end-namelengthmax+4:end),'_avp'];
%         end
    else
%         if length([figname,'_avp'])<=namelengthmax
            dirname=[figname,'_avp'];
%         else
%             dirname=[figname(end-namelengthmax+4:end),'_avp'];
%         end
    end
    mkdir (dirname);
    cd (dirname);
        
    for j=1:nomodes_lo
        clf();
        for k=1:nomodes_hi
            Mean=sum(M(:,k,j))/nobins;
            rows=ceil(sqrt(nomodes_hi));
            cols=ceil(nomodes_hi/rows);
            subplot(rows,cols,k);
            plot(bincenters/pi,1,'-',bincenters/pi,M(:,k,j)/Mean);
%             axis([-1 1 0 Ymax]);
            if nargin>3 
                if ceil(k/cols)==rows
                    xlabel(['Phase of ',P_labels{j},' Component (\pi)']);
                end
                ylabel(['Amp. of ',A_labels{k},' Component']);
            else
                if ceil(k/cols)==rows
                    xlabel(['Phase of Component',num2str(j)]);
                end
                ylabel(['Amp. of Component',num2str(k)]);
            end
        end
        if nargin>3
%             if length(['p_',P_labels{j},'_avp.fig'])<=namelengthmax
                saveas(gcf,['p_',P_labels{j},'_avp.fig']);
%             elseif length([P_labels{j},'.fig'])<=namelengthmax
%                 saveas(gcf,[P_labels{j},'.fig']);
%             else
%                 saveas(gcf,['p_',num2str(j),'_avp.fig'])
%             end
        else
            saveas(gcf,['p_',num2str(j),'_avp.fig']);
        end
    end
    
    close(gcf);
    cd (present_dir);
    
else

    if nargin>3
        A_band_labels=['a_',A_labels{1},'_to_',A_labels{end}];
        P_band_labels=['p_',P_labels{1},'_to_',P_labels{end}];
%         if length([figname,'_',A_band_labels,'_v_',P_band_labels])<=namelengthmax
            dirname=[figname,'_',A_band_labels,'_v_',P_band_labels];
%         elseif length([figname,'_avp'])<=namelengthmax
%             dirname=[figname,'_avp'];
%         else
%             dirname=[figname(end-namelengthmax+4:end),'_avp'];
%         end
    else
%         if length([figname,'_avp'])<=namelengthmax
            dirname=[figname,'_avp'];
%         else
%             dirname=[figname(end-namelengthmax+4:end),'_avp'];
%         end
    end
    mkdir (dirname);
    cd (dirname);
        
    for j=1:nomodes_lo
        for k=1:nomodes_hi
            Mean=sum(M(:,k,j))/nobins;
            clf;
            plot(bincenters/pi,Mean,'-',bincenters/pi,M(:,k,j));
%             axis([-1 1 0 Ymax]);
            if nargin>3
                xlabel(['Phase of ',P_labels{j},' Component (\pi)']);
                ylabel(['Amp. of ',A_labels{k},' Component']);
%                 if length(['a_',A_labels{k},'_v_p_',P_labels{j},'.fig'])<=namelengthmax
                    saveas(gcf,['a_',A_labels{k},'_v_p_',P_labels{j},'_curve.fig']);
%                 elseif length([A_labels{k},'_v_',P_labels{j},'.fig'])<=namelengthmax
%                     saveas(gcf,[A_labels{k},'_v_',P_labels{j},'.fig']);
%                 else
%                     saveas(gcf,['a_',num2str(k),'_v_p_',num2str(j),'.fig'])
%                 end
            else
                xlabel(['Phase of Component',num2str(j)]);
                ylabel(['Amp. of Component',num2str(k)]);
                saveas(gcf,['a',num2str(k),'_v_p_',num2str(j),'_curve.fig']);
            end
        end
    end
    
    close(gcf);
    cd (present_dir);
    
end

