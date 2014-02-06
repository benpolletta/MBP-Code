function [M,MI,p]=CFC_He(hhtdata,nobins,units)

% Finds and plots amplitude vs. phase curves for each pair of modes in the
% EMD of a signal. hhtdata is a matrix whose columns are the EMD modes of a
% signal. nobins is the number of bins the phase interval [-pi,pi] is
% divided into for the amplitude vs. phase curves. units says where the
% indices on a graph of the signal are drawn.

[signal_length,nomodes]=size(hhtdata);

H=[]; A=[]; P=[]; SI=[]; p=[]; z=[];

t=[1:signal_length]/units;

H=hilbert(hhtdata);
A=abs(H);

figure();

for i=1:nomodes
    P(:,i)=phase(H(:,i));
    
    subplot(nomodes,3,3*i-2);
    plot(t,hhtdata(:,i));
    subplot(nomodes,3,3*i-1);
    plot(t,A(:,i));
    subplot(nomodes,3,3*i);
    plot(t,mod(P(:,i),2*pi));
end

% Computing phase coherence.

[SI,PrefPhase]=coherence(nomodes,A,P,1);

% Calculating p-value for SI using bootstrap.

S=floor(rand(1,10)*signal_length);
I=1:signal_length;
figure();
for i=1:10
    I_s=mod(I+S(i),signal_length)+1;
    subplot(3,4,i)
    plot(I,I_s)
    for i=1:nomodes
        P_s(:,i)=P(I,i);
    end
    [SI_s(i,:,:),PrefPhase_s(i,:,:)]=coherence(nomodes,A,P_s,0);
end

for j=1:nomodes
    for k=1:nomodes
    p(j,k)=length(find(SI_s(:,j,k)<SI(j,k)))/10;
    z(j,k)=(SI(j,k)-mean(SI_s(:,j,k)))/std(SI_s(:,j,k));
    end
end

p=reshape(p,nomodes,nomodes);
z=reshape(z,nomodes,nomodes);

% Plotting p.

figure();

p_ext=ones(nomodes+1,nomodes+1);
p_ext(1:nomodes,1:nomodes)=p'; % For the plot, we want k to be rows, j to be columns.
pcolor(p_ext)
colorbar

% Plotting z.

figure();

z_ext=ones(nomodes+1,nomodes+1);
z_ext(1:nomodes,1:nomodes)=z'; % For the plot, we want k to be rows, j to be columns.
pcolor(z_ext)
colorbar