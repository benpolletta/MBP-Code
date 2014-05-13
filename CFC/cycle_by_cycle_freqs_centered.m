function [Freqs]=cycle_by_cycle_freqs_centered(H,sampling_freq)

% tic; P = inc_phase(H); toc;

P = unwrap(angle(H));

[signal_length, nomodes] = size(P);

Freqs = zeros(signal_length,nomodes);

for i = 1:nomodes
    
    phases = P(:,i);
    
    for j = 1:signal_length
        
        local_phases = phases;
        
        phase = local_phases(j,i);
        
        cycle_indicator_temp = (phase - pi <= local_phases(:,i) & local_phases(:,i) < phase + pi);
    
        diff_cycle_indicator = diff(cycle_indicator_temp);
        
        cycle_entrances = find(diff_cycle_indicator == 1) + 1;
        cycle_entrances(cycle_entrances > j) = [];
        if isempty(cycle_entrances)
            cycle_entrance = j;
        else
            cycle_entrance = cycle_entrances(end);
        end
        
        cycle_exits = find(diff_cycle_indicator == -1);
        cycle_exits(cycle_exits < j) = [];
        if isempty(cycle_exits)
            cycle_exit = j;
        else
            cycle_exit = cycle_exits(1);
        end
            
        cycle_length = cycle_exit - cycle_entrance;
        cycle_proportion = (local_phases(cycle_exit,i) - local_phases(cycle_entrance,i))/(2*pi);
        Freqs(j,i) = sampling_freq*cycle_proportion./cycle_length;
        
    end
        
end