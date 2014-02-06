function [f,data_hat,bins,signals,A,P,M,Anova,MI,PAC,mag,dir,Rho,Rho1,n,m]=CFC_fft(dataname,sampling_freq,nobands,nobins,dataname2)

% Finds and plots amplitude vs. phase curves for each pair of modes in the
% EMD of a signal. hhtdata is a matrix whose columns are the EMD modes of a
% signal. nobins is the number of bins the phase interval [-pi,pi] is
% divided into for the amplitude vs. phase curves.

if ischar(dataname)
    data=load(dataname);
elseif isvector(dataname)
    data=dataname;
    dataname=dataname2;
else
    display('First argument to CFC_fft must be either a vector of data, or the filename of a textfile containing a vector of data.')
end

signal_length=length(data);

[f,data_hat,bins,signals,A,P,Pmod]=plotfft(data,sampling_freq,nobands,dataname);

% Plotting amplitudes vs. values, amplitudes vs. amplitudes, amplitudes vs.
% phases.

% valmax=max(max(data));
% valmin=min(min(data));
% ampmax=max(max(A));

figure();

for j=1:nobands
    for k=j:nobands
        subplot(nobands,nobands,nobands*(k-1)+j);
        plot(signals(:,j),A(:,k),'o','MarkerSize',6);
        %axis([valmin valmax 0 ampmax]);
        ylabel([num2str(bins(k,1)),' to ',num2str(bins(k,2)),' Band Amplitude']);
        xlabel([num2str(bins(j,1)),' to ',num2str(bins(j,2)),' Band Signal']);
    end
end

saveas(gcf,[dataname,'fft_amp_vs_signal.fig']);

figure();

for j=1:nobands
    for k=j:nobands        
        subplot(nobands,nobands,nobands*(k-1)+j);
        plot(A(:,j),A(:,k),'o');
        %axis([0 ampmax 0 ampmax]);
        ylabel([num2str(bins(k,1)),' to ',num2str(bins(k,2)),' Band']);
        xlabel([num2str(bins(j,1)),' to ',num2str(bins(j,2)),' Band']);
    end
end

saveas(gcf,[dataname,'fft_amp_vs_amp.fig']);

figure();

for j=1:nobands
    for k=j:nobands
        subplot(nobands,nobands,nobands*(k-1)+j);
        plot(Pmod(:,j),A(:,k),'o');
        %axis([-1 1 0 ampmax]);
        ylabel([num2str(bins(k,1)),' to ',num2str(bins(k,2)),' Band Amplitude']);
        xlabel([num2str(bins(j,1)),' to ',num2str(bins(j,2)),' Band Phase']);
    end
end

saveas(gcf,[dataname,'fft_amp_vs_phase.fig']);
    
% Computing amplitude vs. phase distributions.

[M,N,L,Anova]=amp_v_phase(nobins,A,P,1,[dataname,'fft_']);

% Finding inverse entropy measure for each pair of modes.

MI=inv_entropy(nobands,nobins,M,[dataname,'fft_']);

% Computing Ozkurt's direct phase-amplitude coupling estimator.

PAC=directPAC(P,A,[dataname,'fft_']);

% Computing phase coherence of amplitude and signal (following Cohen).

[mag,dir]=phase_amp_coherence(P,A,[dataname,'fft_']);

% Computing cross-correlation of amplitude with mode.

figure();

Rho=zeros(nobands,nobands);
%[Rho,Pval]=corr(hhtdata,A);
for l=1:nobands % Index for signal.
    for m=l:nobands % Index for amplitude.
        lags=[]; correlations=[];
        [rho,correlations,lags]=lagged_corr(signals(:,l),P(:,l),A(:,m));
        Rho(l,m)=rho;
        subplot(nobands,nobands,nobands*(m-1)+l);
        plot(lags,correlations);
        v=axis;
        axis([v(1) v(2) -1 1]);
        title(['Corr(M_',num2str(l),',A_',num2str(m),')']);
        xlabel('Lag');
        ylabel('Coefficient');
    end
end

saveas(gcf,[dataname,'fft_lag_corr.fig']);

figure();

% subplot(1,2,1);
colorplot(Rho');
title('Lagged Signal-Amplitude Correlation Coefficient');
xlabel('Signal (Band Number)');
ylabel('Amplitude (Band Number)');

saveas(gcf,[dataname,'fft_lag_corr_coeff.fig']);

% subplot(1,2,2);
% colorplot(Pval);
% title('Cross-Mode Signal-Amplitude Correlation P-Value');
% ylabel('Signal (Mode Number)');
% xlabel('Amplitude (Mode Number)');

[Rho1,Pval1]=corr(A);
figure();

% subplot(1,2,1);
colorplot(Rho1);
title('Cross-Mode Amplitude-Amplitude Correlation Coefficient');
ylabel('Band Number');
xlabel('Band Number');

[n,m,dphase,mag,dir]=n_m_phaselocking(P,Pmod);

% subplot(1,2,2);
% colorplot(Pval1);
% title('Cross-Mode Amplitude-Amplitude Correlation P-Value');
% ylabel('Mode Number');
% xlabel('Mode Number');