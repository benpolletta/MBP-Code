function [bands]=emd_find_freqs(P,sampling_freq)

bands=[];

[signal_length,nomodes]=size(P);

cycleno=floor(P/(2*pi));
no_cycles=P(end,:)/(2*pi);
freqs=sampling_freq*no_cycles/signal_length;

for i=1:nomodes
    cycle_bounds=find(diff(cycleno(:,i))>0);
    max_cycle_length=max(diff(cycle_bounds));
    min_cycle_length=min(diff(cycle_bounds));

    if length(cycle_bounds)>1
        bands(i,:)=[sampling_freq/max_cycle_length freqs(i) sampling_freq/min_cycle_length];
    else
        bands(i,:)=[0 freqs(i) sampling_freq/signal_length];
    end
    
end
    