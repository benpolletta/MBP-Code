function plotHAP_Jan(H,A,P,bands,sampling_freq,units,filename)

Pmod=mod(P,2*pi)/pi;

H=detrend(H,'constant');
A=detrend(A,'constant');
Pmod=detrend(Pmod,'constant');

H_space=max(max(real(H))-min(real(H)));
A_space=max(max(A)-min(A));

[signal_length,nomodes]=size(H);
t=1:signal_length;
t=t/sampling_freq;

figure();
    
subplot(1,3,1)

for i=1:nomodes

    plot(t,real(H(:,i))+(i-1)*H_space)
    hold on

end

title('Components')
ylabel('Mode #')
set(gca,'YTick',[0:H_space:H_space*(nomodes-1)],'YTickLabel',bands(:,2))
ylim([-H_space,nomodes*H_space])

subplot(1,3,2)

for i=1:nomodes

    plot(t,A(:,i)+(i-1)*A_space)
    hold on

end

title('Amplitudes')
% ylabel('Mode #')
xlabel('Time (s)')
set(gca,'YTick',[0:A_space:A_space*(nomodes-1)],'YTickLabel',bands(:,2))
ylim([-A_space,nomodes*A_space])

subplot(1,3,3)

for i=1:nomodes

    plot(t,Pmod(:,i)+(i-1)*3)
    hold on
    
end

title('Phases')
% ylabel('Mode #')
xlabel('Time (s)')
set(gca,'YTick',[0:3:3*(nomodes-1)],'YTickLabel',bands(:,2))
ylim([-3,nomodes*3])

saveas(gcf,[filename,'_modes.fig'])
close(gcf)

figure();

subplot(3,1,1)

colorplot(real(H'))
axis xy
title('Components')
ylabel(['Frequency ',char(units)])
% xlabel('Time (ms)')
set(gca,'YTick',[1.5:nomodes+1.5],'YTickLabel',bands(:,2))

subplot(3,1,2)

colorplot(A')  
axis xy
title('Amplitudes')
ylabel(['Frequency ',char(units)])
% xlabel('Time (ms)')
set(gca,'YTick',[1.5:nomodes+1.5],'YTickLabel',bands(:,2))

subplot(3,1,3)

colorplot(Pmod')
axis xy
title('Phases')
ylabel(['Frequency ',char(units)])
xlabel('Time (ms)')
set(gca,'YTick',[1.5:nomodes+1.5],'YTickLabel',bands(:,2))

saveas(gcf,[filename,'_modes_colorplot.fig'])
close(gcf)