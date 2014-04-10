function [Freqs]=cycle_by_cycle_freqs_centered(H,sampling_freq)

P = inc_phase(H);

[signal_length, nomodes] = size(P);

Freqs = zeros(signal_length,nomodes);

for i = 1:nomodes
    
    for j = 1:signal_length
    
        phase = P(j,i);
        
        cycle_indicator_temp = (phase - 2*pi <= P & P < phase + 2*pi);
    
        diff_cycle_indicator = diff(cycle_temp);
        
        cycle_entrances = find(diff_cycle_indicator == 1) + 1;
        cycle_entrances(cycle_entrances > j) = [];
        cycle_entrance = cycle_entrances(end);
        
        cycle_exits = find(diff_cycle_indicator == -1);
        cycle_exits(cycle_exits < j) = [];
        cycle_exit = cycle_exits(1);

        cycle_length = cycle_exit - cycle_entrance;
        cycle_proportion = (P(cycle_exit,i) - P(cycle_entrance,i))/(2*pi);
        Freqs(j,i) = sampling_freq*cycle_proportion./cycle_lengths;
        
    end
        
end