function emd_inv_entropy_plot_scatter(MI,F,units,filename)

[noamps,nophases]=size(MI);

if noamps==nophases
    nomodes=noamps;
else
    display('MI must be square.')
end

MI=triu(MI,1);
maxMI=max(max(MI));

[sorted,indices]=sort(reshape(MI,noamps*nophases,1));
Rank=zeros(noamps,nophases);
for i=1:noamps
    for j=1:nophases
        Rank(i,j)=find(indices==noamps*(j-1)+i);
    end
end

badranks=max(max(tril(Rank)));
indices=indices(badranks+1:end);
Rank=triu(Rank-badranks,1);
toprank=max(max(Rank));

% cmap=jet(1000);
cmap=gray(1000);
MIcolors=max(round(1000*MI/maxMI),1);

figure()
% whitebg
whitebg(cmap(1,:))
alpha(.1)

for k=1:toprank
    [I,J]=find(Rank==k);
    if MI(I,J)~=0
        plot(F(:,J),F(:,I),'.','color',cmap(MIcolors(I,J),:))
        hold on
    end
end

ticks=0:8:64;
colorbar('YTick',ticks,'YTickLabel',maxMI*ticks/64)
title('Inverse Entropy Value for Phase-Amplitude Modulation')

% % Changing axis so it is tight to significant MI values.
% colsum=sum(MI);
% rowsum=sum(MI,2);
% nullcols=find(colsum==0);
% nullrows=find(rowsum==0);
% x_lim_F=F;
% x_lim_F(:,nullcols)=NaN;
% y_lim_F=F;
% y_lim_F(:,nullrows)=NaN;
% axis([min(min(x_lim_F)) max(max(x_lim_F)) min(min(y_lim_F)) max(max(y_lim_F))])

if nargin>2
    xlabel(['Phase-Modulating Frequency (',units,', by Cycle)'])
    ylabel(['Amplitude-Modulated Frequency (',units,', by Cycle)'])
else
    xlabel(['Phase-Modulating Frequency (by Cycle)'])
    ylabel(['Amplitude-Modulated Frequency (by Cycle)'])
end

if nargin>3
    saveas(gcf,[filename,'_inv_entropy_scatter.fig'])
end

