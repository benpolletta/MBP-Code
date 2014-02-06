function emd_inv_entropy_plotter_new(MI,A_bands,P_bands,units)

[noamps,nophases]=size(MI);

[sorted,indices]=sort(reshape(MI,noamps*nophases,1));

figure();
%alpha(0.5)

cmap=jet(noamps*nophases);

for i=noamps:-1:1
    A_low=A_bands(i,1);
    A_width=A_bands(i,3)-A_low;
    for j=i+1:nophases
        rank=find(indices==noamps*(i-1)+j);
        P_low=P_bands(j,1);
        P_width=P_bands(j,3)-P_low;
        if A_width==0 & P_width==0
            plot(P_low,A_low,'color',cmap(rank,:));
        elseif A_width==0
            line([P_low P_bands(j,3)],[A_low A_low],'color',cmap(rank,:))
        elseif P_width==0
            line([P_low P_low],[A_low A_bands(j,3)],'color',cmap(rank,:))
        else
            rectangle('Position',[P_low,A_low,P_width,A_width],'FaceColor',cmap(rank,:))
        end
        hold on
    end
end