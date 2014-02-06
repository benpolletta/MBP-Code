function [H,A,P,M,Anova,MI,PAC,mag,dir,Rho,Rho1,n,m]=CFC_fft(data,nobands,nobins)

% Finds and plots amplitude vs. phase curves for each pair of modes in the
% EMD of a signal. hhtdata is a matrix whose columns are the EMD modes of a
% signal. nobins is the number of bins the phase interval [-pi,pi] is
% divided into for the amplitude vs. phase curves.

signal_length=length(data);
nyquist=.5;

lo_band_spacing=(nyquist/10-1/signal_length)/nobands_lo;
bandwidth_lo=2*lo_band_spacing/5
lo_band_centers=1/signal_length+bandwidth_lo:lo_band_spacing:nyquist/10+bandwidth_lo

bandwidth_hi=nyquist/(5*nobands_hi)
hi_band_centers=nyquist/nobands_hi:nyquist/nobands_hi:nyquist

data_hat=fft(data);

low_f_signals=[];

for i=1:nobands_lo
    flo=lo_band_centers(i)-bandwidth_lo;
    fhi=lo_band_centers(i)+bandwidth_lo;
    filter=butterworth(3,signal_length,1,flo,fhi,0);
    filtered=data_hat.*sqrt(filter);
    low_f_signals(:,i)=ifft(filtered);
end

[Hlo,Alo,Plo,Pmod_lo]=plotHAP(low_f_signals);

hi_f_signals=[];

for i=1:nobands_hi
    flo=hi_band_centers(i)-bandwidth_hi;
    fhi=hi_band_centers(i)+bandwidth_hi;
    filter=butterworth(3,signal_length,1,flo,fhi,0);
    filtered=data_hat.*sqrt(filter);
    hi_f_signals(:,i)=ifft(filtered);
end

[Hhi,Ahi,Phi,Pmod_hi]=plotHAP(hi_f_signals);

% Plotting amplitudes vs. values, amplitudes vs. amplitudes, amplitudes vs.
% phases.

% valmax=max(max(hhtdata));
% valmin=min(min(hhtdata));
% ampmax=max(max(A));

fig_avv=figure();
fig_ava=figure();
fig_avp=figure();

for j=1:nomodes
    for k=1:nomodes
        figure(fig_avv)
        subplot(nomodes,nomodes,nomodes*(k-1)+j);
        plot(hhtdata(:,j),A(:,k),'o','MarkerSize',6);
        %axis([valmin valmax 0 ampmax]);
        ylabel(['Amp., Mode ',num2str(k)]);
        xlabel(['Value, Mode ',num2str(j)]);
        
        figure(fig_ava)
        subplot(nomodes,nomodes,nomodes*(k-1)+j);
        plot(A(:,j),A(:,k),'o');
        %axis([0 ampmax 0 ampmax]);
        ylabel(['Amp., Mode ',num2str(k)]);
        xlabel(['Amp., Mode ',num2str(j)]);
        
        figure(fig_avp)
        subplot(nomodes,nomodes,nomodes*(k-1)+j);
        plot(Pmod(:,j),A(:,k),'o');
        %axis([-1 1 0 ampmax]);
        ylabel(['Amp., Mode ',num2str(k)]);
        xlabel(['Phase, Mode ',num2str(j)]);
    end
end
    
% Computing amplitude vs. phase distributions.

[M,N,L,Anova]=amp_v_phase(nobins,A,P,1);

% Finding inverse entropy measure for each pair of modes.

MI=inv_entropy(nomodes,nobins,M);

% Computing Ozkurt's direct phase-amplitude coupling estimator.

PAC=directPAC(P,A);

% Computing phase coherence of amplitude and signal (following Cohen).

[mag,dir]=phase_amp_coherence(P,A);

% Computing cross-correlation of amplitude with mode.

figure();

Rho=zeros(nomodes,nomodes);
%[Rho,Pval]=corr(hhtdata,A);
for l=1:nomodes % Index for signal.
    for m=1:nomodes % Index for amplitude.
        lags=[]; correlations=[];
        [rho,correlations,lags]=lagged_corr(hhtdata(:,l),P(:,l),A(:,m));
        Rho(l,m)=rho;
        subplot(nomodes,nomodes,nomodes*(m-1)+l);
        plot(lags,correlations);
        v=axis;
        axis([v(1) v(2) -1 1]);
        title(['Corr(M_',num2str(l),',A_',num2str(m),')']);
        xlabel('Lag');
        ylabel('Coefficient');
    end
end

figure();

% subplot(1,2,1);
colorplot(Rho');
title('Lagged Signal-Amplitude Correlation Coefficient');
xlabel('Signal (Mode Number)');
ylabel('Amplitude (Mode Number)');

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
ylabel('Mode Number');
xlabel('Mode Number');

[n,m,dphase,mag,dir]=n_m_phaselocking(P,Pmod);

% subplot(1,2,2);
% colorplot(Pval1);
% title('Cross-Mode Amplitude-Amplitude Correlation P-Value');
% ylabel('Mode Number');
% xlabel('Mode Number');