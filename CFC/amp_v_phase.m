function [M,N,L,Anova]=amp_v_phase(nobins,A,P,figchoice,figname,A_bands,P_bands)

% Finding amplitude vs. phase curves for each pair of modes. nobins is the 
% number of bins, A is a matrix whose columns are the amplitudes of the modes, 
% P is a matrix whose columns are the phases of the modes, figchoice is 
% either 1 (to make a figure) or 0 (to omit the figure). A_bands is a matrix of
% mins, centers and maxes for the frequency bands of the amplitude-modulated 
% components. P_bands gives the same for the phase-modulating components.

[nopoints,nomodes_hi]=size(A);
[nopoints,nomodes_lo]=size(P);
bincenters=[1:nobins];
bincenters=(bincenters-1)*2*pi/nobins-pi*(nobins-1)/nobins;

Pmod=mod(P,2*pi)-pi;

for j=1:nomodes_lo     % Counter for modes providing phase.
    amp_index=0;    % Index for recording all amplitudes in each phase bin.
    for i=1:nobins  % Counter for phase bins.
        indices=[];
        indices=find(bincenters(i)-pi/nobins<=Pmod(:,j) & Pmod(:,j)<bincenters(i)+pi/nobins);   % Bin phases.
        for k=1:nomodes_hi     % Counter for modes providing amplitude. 
            if length(indices)~=0
                M(i,j,k)=sum(A(indices,k))/length(indices); % Average amplitude of mode k around phase i of mode j.
                N(amp_index+1:amp_index+length(indices),j,k)=A(indices,k);  % Amplitudes of mode k around phase i of mode j.
                L(amp_index+1:amp_index+length(indices),j,k)=bincenters(i)/pi; % Vector recording that these amplitudes occur at phase i of mode j.
            else
                M(i,j,k)=0;
            end
        end
        amp_index=amp_index+length(indices);    % Index at which vector of amplitudes ends.
    end
end

%Plotting amplitude vs. phase curves for each pair of modes.

if figchoice==1

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

% figure();
% 
% for j=1:nomodes
%     for k=1:nomodes        
%         subplot(nomodes,nomodes,nomodes*(k-1)+j);
%         boxplot(N(:,j,k),L(:,j,k));
%         %v=axis;
%         %axis([v(1) v(2) 0 Ymax]);
%         xlabel(['Phase of ',P_labels(j),' (\pi)']);
%         ylabel(['Amp. of ',A_labels(k)]);
%         
%         Anova(j,k)=kruskalwallis(N(:,j,k),L(:,j,k),'off');
%     end
% end
% 
% if nargin>4
%     saveas(gcf,[figname,'fft_avp_boxplot.fig']);
% end
%     
% figure();
% colorplot(Anova');
% title('ANOVA Results for Amplitude Binned by Phase');
% xlabel('Mode Number (Phase)');
% ylabel('Mode Number (Amplitude)');
% 
% saveas(gcf,[figname,'fft_anova.fig']);

end