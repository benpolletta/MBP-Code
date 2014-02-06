
figure();
subplot(1,2,1)
t=1:signal_length;
t=t/sampling_freq;
plot(t,data)
title('Data')
subplot(1,2,2)
indices=1:signal_length/2;
f=sampling_freq*(indices'-1)/signal_length;
plot(f,abs(data_hat(1:signal_length/2)))
title('FFT (Amplitude)')

for j=1:nobands

    flo=bands(j,3*(i-1)+1);
    fhi=bands(j,3*i);
    bandnames{bandindex}=[num2str(flo),' to ',num2str(fhi)];

    if nobands(i)>10
        clf();

        subplot(3,1,1);
        plot(t,signals(:,bandindex));
        title([bandnames{bandindex},' Hz Band'])

        subplot(3,1,2);
        plot(t,A(:,bandindex));
        title(['Amplitude of ',bandnames{bandindex},' Hz Band']);

        subplot(3,1,3);
        plot(t,Pmod(:,bandindex));
        title(['Phase of ',bandnames{bandindex},' Hz Band']);

        if ~isempty(filename)
            saveas(gcf,[filename,'_',bandnames{bandindex},'_band.fig']);
        end
    else
        subplot(nobands,3,3*i-2);
        plot(signals(:,i));
        title([bandnames{bandindex},' Hz Band'])

        subplot(nobands,3,3*i-1);
        plot(A(:,i));
        title(['Amplitude of ',bandnames{bandindex},' Hz Band']);

        subplot(nobands,3,3*i);
        plot(Pmod(:,i));
        title(['Phase of ',bandnames{bandindex},' Hz Band']);
    end
    
end

if nobands(i)<=10 & ~isempty(filename) & noranges>1
    saveas(gcf,[filename,'_fft_bands_',num2str(i),'.fig']);
elseif nobands(i)<=10 & ~isempty(filename)
    saveas(gcf,[filename,'_fft_bands.fig']);
end

close(gcf);