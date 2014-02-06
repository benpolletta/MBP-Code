function plotHAP(H,A,P,bands,sampling_freq,units,filename,dirname)

Pmod=mod(P,2*pi)/pi;

[signal_length,nomodes]=size(H);
t=1:signal_length;
t=t/sampling_freq;

figure();

for i=1:nomodes
    
    modelabel=[num2str(bands(i,2)),' (',num2str(bands(i,1)),' to ',num2str(bands(i,3)),') ',char(units)];
    
    if nomodes>10
        clf();

        subplot(3,1,1);
        plot(t,real(H(:,i)));
        title(['Mode ',num2str(i),', ',modelabel])

        subplot(3,1,2);
        plot(t,A(:,i));
        title(['Amplitude of Mode ',num2str(i),', ',modelabel]);

        subplot(3,1,3);
        plot(t,Pmod(:,i));
        title(['Phase of Mode ',num2str(i),', ',modelabel]);

        if nargin>6
            if nargin>7
                saveas(gcf,[dirname,'\',filename,'_mode_',num2str(i),'.fig']);
            else
                saveas(gcf,[filename,'_mode_',num2str(i),'.fig']);
            end
        end
        
    else
        subplot(nomodes,3,3*i-2);
        plot(t,real(H(:,i)));
        title(['Mode ',num2str(i),', ',modelabel])

        subplot(nomodes,3,3*i-1);
        plot(t,A(:,i));
        title(['Amplitude of Mode ',num2str(i),', ',modelabel]);

        subplot(nomodes,3,3*i);
        plot(t,Pmod(:,i));
        title(['Phase of Mode ',num2str(i),', ',modelabel]);
    end
    
end

if nomodes<=10 & nargin>6
    if nargin>7
        saveas(gcf,[dirname,'\',filename,'_modes.fig']);
    else
        saveas(gcf,[filename,'_modes.fig']);
    end
end