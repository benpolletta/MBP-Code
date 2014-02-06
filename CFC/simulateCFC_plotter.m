function simulateCFC_plotter(noise,lo_mode,hi_amp,hi_mode,s,s_noise,filename)

figure();

subplot(3,2,1)
plot(lo_mode)
title('Low-frequency Component')

subplot(3,2,2)
plot(s)
title('Signal Without Noise')

subplot(3,2,3)
plot(hi_amp)
title('High-frequency Amplitude Envelope')

subplot(3,2,4)
plot(noise)
title('Noise')

subplot(3,2,5)
plot(hi_mode)
title('High-frequency Component')

subplot(3,2,6)
plot(s_noise)
title('Signal With Noise')

saveas(gcf,[char(filename),'.fig'])