function P=inc_phase(hilbertdata)

[r,c]=size(hilbertdata);

P=angle(hilbertdata);

dP=diff(P);

for i=1:c
    negs=find(dP(:,i)<-pi/2);
    for j=1:length(negs)
        P(:,i)=P(:,i)+2*pi*[zeros(negs(j),1); ones(r-negs(j),1)];
    end
    wraps=find(dP(:,i)>3*pi/2);
    for k=1:length(wraps)
        P(:,i)=P(:,i)-2*pi*[zeros(wraps(k),1); ones(r-wraps(k),1)];
    end
end
