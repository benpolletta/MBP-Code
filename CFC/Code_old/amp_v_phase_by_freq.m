function [x_bin_centers,y_bin_centers,bincenters,M]=amp_v_phase_by_freq(nobins,A,F,P,x_lims,y_lims,x_bins,y_bins)

% Finding amplitude vs. phase curves for each frequency bin given by the
% last four arguments. nobins is the number of bins, A is a matrix whose
% columns are the amplitudes of the modes, P is a matrix whose columns are
% the phases of the modes, figchoice is either 1 (to make a figure) or 0
% (to omit the figure). A_bands is a matrix of mins, centers and maxes for
% the frequency bands of the amplitude-modulated components. P_bands gives
% the same for the phase-modulating components.

[nopoints,nomodes]=size(A);

clear bincenters
bincenters=1:nobins;
bincenters=(bincenters-1)*2*pi/nobins-pi*(nobins-1)/nobins;

Pmod=mod(P,2*pi)-pi;

x_bin_width=(x_lims(2)-x_lims(1))/x_bins;
x_bins_low=x_lims(1):x_bin_width:(x_lims(2)-x_bin_width);
x_bins_high=x_bins_low+x_bin_width;
x_bin_centers=(x_bins_high+x_bins_low)/2;

y_bin_width=(y_lims(2)-y_lims(1))/y_bins;
y_bins_low=y_lims(1):y_bin_width:(y_lims(2)-y_bin_width);
y_bins_high=y_bins_low+y_bin_width;
y_bin_centers=(y_bins_high+y_bins_low)/2;

M=zeros(nobins,x_bins,y_bins);
noamps=zeros(nobins,x_bins,y_bins);

for j=1:nomodes
    for l=1:x_bins
        phase_times=find(x_bins_low(l)<=F(:,j) & F(:,j)<x_bins_high(l));
        if ~isempty(phase_times)
            for i=1:nobins  % Counter for phase bins.
                indices=[];
                indices=find(bincenters(i)-pi/nobins<=Pmod(phase_times,j) & Pmod(phase_times,j)<bincenters(i)+pi/nobins);   % Bin phases.
                for k=1:y_bins
                    amps=A(y_bins_low(k)<=F(indices,:) & F(indices,:)<y_bins_high(k));              
                    if length(amps)~=0
                        noamps(i,k,l)=noamps(i,k,l)+length(amps);
                        M(i,k,l)=M(i,k,l)+sum(amps); % Amplitudes in frequency bin k around phase i of cycles in frequency bin l of mode j.
                    end
                end
            end
        end
    end
end

M=M./noamps;

figure();
for i=1:y_bins 
    for j=1:x_bins 
        subplot(x_bins,y_bins,(i-1)*x_bins+j) 
        plot(bincenters/pi,M(:,i,j)) 
        xlabel(['Phase ~',num2str(x_bin_centers(j)),' Hz'])
        ylabel(['Amp. ~',num2str(y_bin_centers(i)),' Hz'])
    end 
end