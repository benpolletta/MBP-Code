function HAF_plotter(H,A,F,bands,sampling_freq,units,filename,dirname)

[signal_length,nomodes]=size(H);
t=1:signal_length;
t=t/sampling_freq;

data(:,:,1)=real(H); data(:,:,2)=A; data(:,:,3)=F;
label{1}='Mode '; label{2}='Amplitude of Mode '; label{3}='Frequency of Mode ';

if nomodes>10 & nomodes<=30
    
    lbl{1}='_modes'; lbl{2}='_amps'; lbl{3}='_freqs';
    
    cols=ceil(sqrt(nomodes));
    rows=ceil(nomodes/cols);
    
    figure();
    
    for j=1:3
        
        clf();
        
        for i=1:nomodes
            
            if nargin>5
                modelabel=[num2str(bands(i,2)),' (',num2str(bands(i,1)),' to ',num2str(bands(i,3)),') ',char(units)];
            else
                modelabel=[num2str(bands(i,2)),' (',num2str(bands(i,1)),' to ',num2str(bands(i,3)),')'];
            end
            
            subplot(rows,cols,i)
            plot(t,data(:,i,j))
            title([label{j},num2str(i),', ',modelabel])
            
        end

        if nargin>6
            if nargin>7 & ~isempty(dirname)
                present_dir=pwd;
                cd (dirname);
                saveas(gcf,[filename,lbl{j},'.fig']);
                cd (present_dir);
            else
                saveas(gcf,[filename,lbl{j},'.fig']);
            end
        end

    end

else
    
    figure();

    for i=1:nomodes

        if nargin>5
            modelabel=[num2str(bands(i,2)),' (',num2str(bands(i,1)),' to ',num2str(bands(i,3)),') ',char(units)];
        else
            modelabel=[num2str(bands(i,2)),' (',num2str(bands(i,1)),' to ',num2str(bands(i,3)),')'];
        end

        if nomodes>10

            clf();

            for j=1:3
                
                subplot(3,1,j);
                plot(t,data(:,i,j));
                title([label{j},num2str(i),', ',modelabel])
                
            end
                
%             subplot(3,1,1);
%             plot(t,real(H(:,i)));
%             title(['Mode ',num2str(i),', ',modelabel])
% 
%             subplot(3,1,2);
%             plot(t,A(:,i));
%             title(['Amplitude of Mode ',num2str(i),', ',modelabel]);
% 
%             subplot(3,1,3);
%             plot(t,Pmod(:,i));
%             title(['Phase of Mode ',num2str(i),', ',modelabel]);

            if nargin>6
                if nargin>7 & ~isempty(dirname)
                    present_dir=pwd;
                    cd (dirname);
                    saveas(gcf,[filename,'_mode_',num2str(i),'.fig']);
                    cd (present_dir);
                else
                    saveas(gcf,[filename,'_mode_',num2str(i),'.fig']);
                end
            end

        else
            
            for j=1:3
                
                subplot(nomodes,3,3*i-(3-j));
                plot(t,data(:,i,j));
                title([label{j},num2str(i),', ',modelabel])
                
            end

%         subplot(nomodes,3,3*i-2);
%         plot(t,real(H(:,i)));
%         title(['Mode ',num2str(i),', ',modelabel])
% 
%         subplot(nomodes,3,3*i-1);
%         plot(t,A(:,i));
%         title(['Amplitude of Mode ',num2str(i),', ',modelabel]);
% 
%         subplot(nomodes,3,3*i);
%         plot(t,F(:,i));
%         title(['Frequency of Mode ',num2str(i),', ',modelabel]);
    
        end
        
    end
    
end

if nomodes<=10 & nargin>6
    if nargin>7 & ~isempty(dirname)
        present_dir=pwd;
        cd (dirname);
        saveas(gcf,[filename,'_modes.fig']);
        cd (present_dir);
    else
        saveas(gcf,[filename,'_modes.fig']);
    end
end

fclose('all')