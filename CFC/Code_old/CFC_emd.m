function [H,A,P,M,MI,PAC,mag,dir,Rho,Rho1,n,m]=CFC_emd(datafile,sampling_freq,nobins,outfilename)

% Finds and plots amplitude vs. phase curves for each pair of modes in the
% EMD of a signal. hhtdata is a matrix whose columns are the EMD modes of a
% signal. nobins is the number of bins the phase interval [-pi,pi] is
% divided into for the amplitude vs. phase curves.

if ischar(datafile)
    hhtdata=load(datafile)';
    datafile=char(datafile);
    dataname=[datafile(1:end-8)];
elseif isfloat(datafile)
    hhtdata=datafile;
    dataname=char(outfilename);
end

dataname=[dataname,'_emd'];

[signal_length,nomodes]=size(hhtdata);

% Calculating Hilbert transform, plotting modes, their amplitudes, and their phases.

[H,A,P,Pmod]=plotHAP(hhtdata,sampling_freq,dataname);

% Computing amplitude vs. phase distributions.

M=amp_v_phase(nobins,A,P,1,dataname);

% Finding inverse entropy measure for each pair of modes.

modes=1:nomodes;
bands_lo(:,2)=modes';
bands_hi(:,2)=modes';

MI=inv_entropy(nobins,M,dataname,bands_hi,bands_lo,'Mode #');

% Computing Ozkurt's direct phase-amplitude coupling estimator.

PAC=directPAC(P,A,dataname);

% Computing phase coherence of amplitude and signal (following Cohen).

[mag,dir]=phase_amp_coherence(P,A,dataname);

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

saveas(gcf,[dataname,'_lag_corr.fig']);

figure();

% subplot(1,2,1);
colorplot(Rho');
axis ij;
title('Lagged Signal-Amplitude Correlation Coefficient');
xlabel('Signal (Mode Number)');
ylabel('Amplitude (Mode Number)');
saveas(gcf,[dataname,'_lag_corr_coeff.fig']);

% subplot(1,2,2);
% colorplot(Pval);
% title('Cross-Mode Signal-Amplitude Correlation P-Value');
% ylabel('Signal (Mode Number)');
% xlabel('Amplitude (Mode Number)');

[Rho1,Pval1]=corr(A);
figure();

% subplot(1,2,1);
colorplot(Rho1);
axis ij;
title('Cross-Mode Amplitude-Amplitude Correlation Coefficient');
ylabel('Mode Number');
xlabel('Mode Number');
saveas(gcf,[dataname,'_amp_amp_corr.fig']);

[n,m,dphase,mag,dir]=n_m_phaselocking(P,Pmod,dataname);

% subplot(1,2,2);
% colorplot(Pval1);
% title('Cross-Mode Amplitude-Amplitude Correlation P-Value');
% ylabel('Mode Number');
% xlabel('Mode Number');