function [M,MI,p,z]=CFC_He(hhtdata,nobins,units)

% Finds and plots amplitude vs. phase curves for each pair of modes in the
% EMD of a signal. hhtdata is a matrix whose columns are the EMD modes of a
% signal. nobins is the number of bins the phase interval [-pi,pi] is
% divided into for the amplitude vs. phase curves. units says where the
% indices on a graph of the signal are drawn.

[signal_length,nomodes]=size(hhtdata);

H=[]; A=[]; P=[]; M=[]; Mean=[]; MI=[]; p=[]; z=[];

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

% Computing amplitude vs. phase curves.

M=amp_v_phase(nomodes,nobins,A,P,1);

% Finding inverse entropy measure for each pair of modes.

MI=inv_entropy(nomodes,nobins,M);

% Plotting MI.

figure();

MI_ext=ones(nomodes+1,nomodes+1);
MI_ext(1:nomodes,1:nomodes)=MI'; % For the plot, we want k to be rows, j to be columns.
pcolor(MI_ext)
colorbar

% Calculating p-value for MI using bootstrap.

Shift=rand(100,nomodes)*2*pi;
for i=1:100
    P_s=P+ones(size(P))*diag(Shift(i,:));
    M_s=amp_v_phase(nomodes,nobins,A,P_s,0);
    MI_s(i,:,:)=inv_entropy(nomodes,nobins,M_s);
end

for j=1:nomodes
    for k=1:nomodes
    p(j,k)=length(find(MI_s(:,j,k)<MI(j,k)))/100;
    z(j,k)=(MI(j,k)-mean(MI_s(:,j,k)))/std(MI_s(:,j,k));
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