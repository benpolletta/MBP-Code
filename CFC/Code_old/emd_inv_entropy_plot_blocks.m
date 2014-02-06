function emd_inv_entropy_plot_blocks(MI,F,units)

[noamps,nophases]=size(MI);

if noamps==nophases
    nomodes=noamps;
else
    display('MI must be square.')
end

MI=triu(MI,1);
maxMI=max(max(MI));

[sorted,indices]=sort(reshape(MI,nomodes^2,1));
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

cmap=jet(1000);
MIcolors=round(1000*MI/maxMI);

figure();
axes('Color',cmap(1,:));
alpha(.1);

for k=1:toprank
    [I,J]=find(Rank==k);
    P_min=min(F(:,J));
    A_min=min(F(:,I));
    P_width=max(F(:,J))-P_min;
    A_width=max(F(:,I))-A_min;
%     if A_width==0 & P_width==0
%         plot(,A_low,'color',cmap(MIcolors(I,J),:));
%     elseif A_width==0
%         line([P_low P_bands(j,3)],[A_low A_low],'color',cmap(MIcolors(I,J),:))
%     elseif P_width==0
%         line([P_low P_low],[A_low A_bands(j,3)],'color',cmap(MIcolors(I,J),:))
%     else
    rectangle('Position',[P_min,A_min,P_width,A_width],'FaceColor',cmap(MIcolors(I,J),:))
    hold on
end

ticks=0:8:64;
colorbar('YTick',ticks,'YTickLabel',maxMI*ticks/64);