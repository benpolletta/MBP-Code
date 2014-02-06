function [Freqs,cycle_bounds,bands,cycle_frequencies]=cycle_by_cycle_freqs(P,sampling_freq)

[signal_length,nomodes]=size(P);

% P=cumsum(abs([P(1,:); diff(P)]));

Freqs=zeros(signal_length,nomodes);

cycleno=floor(P/(2*pi));

for i=1:nomodes
    
    pre_crossings=find(diff(cycleno(:,i))>0);
    
    if length(pre_crossings)==0
        cycle_proportion=(P(end,i)-P(1,i))/2*pi;
        cycle_freq=sampling_freq*cycle_proportion/signal_length;
        
        Freqs(1:end,i)=cycle_freq;
        cycle_bounds{i}=[1 signal_length];
        cycle_frequencies{i}=cycle_freq;
    else
        if pre_crossings(1)==1
            cycle_starts=pre_crossings;
            cycle_ends=[pre_crossings(2:end); signal_length];
            no_freqs=length(pre_crossings);
        else
            cycle_starts=[1; pre_crossings];
            cycle_ends=[pre_crossings; signal_length];
            no_freqs=length(pre_crossings)+1;
        end

        cycle_lengths=cycle_ends-cycle_starts;
        cycle_proportions=(P(cycle_ends,i)-P(cycle_starts,i))/(2*pi);
    %     cycle_proportions(cycle_proportions<0 & cycle_proportions>-1)=1+cycle_proportions(cycle_proportions<0 & cycle_proportions>-1);
    %     cycle_proportions(cycle_proportions<=-1)=abs(cycle_proportions(cycle_proportions<=-1));
        cycle_freqs=sampling_freq*cycle_proportions./cycle_lengths;

        Freqs(1:(pre_crossings(1)-1),i)=cycle_freqs(1);
        for j=2:no_freqs
            Freqs(cycle_starts(j),i)=(cycle_freqs(j-1)+cycle_freqs(j))/2;
            Freqs((cycle_starts(j)+1):(cycle_ends(j)-1),i)=cycle_freqs(j);
        end
        Freqs(end,i)=cycle_freqs(end);
    
        cycle_bounds{i}=[cycle_starts cycle_ends];
        cycle_frequencies{i}=cycle_freqs;
        
        bands=[min(Freqs)' mean(Freqs)' max(Freqs)'];
    end
    
end