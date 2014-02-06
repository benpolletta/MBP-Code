function emd_inv_entropy_plotter_new(MI,F,units)

[noamps,nophases]=size(MI);

if noamps==nophases
    nomodes=noamps;
else
    display('MI must be square.')
end

MI=triu(MI,1);
maxMI=max(max(MI));
minMI=min(min(MI));

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

figure();
alpha(.1);

cmap=jet(1000);
MIcolors=round(1000*MI/(maxMI-minMI));

for k=1:toprank
    [I,J]=find(Rank==k);
    plot(F(:,J),F(:,I),'.','color',cmap(MIcolors(I,J),:));
    hold on
end

ticks=1:7:64;
colorbar('YTick',ticks,'YTickLabel',maxMI*ticks/64);