function run_multivar_PAC_Bernat

[peak_hours, max_phase_freq, max_amp_freq] = hour_peak_summed_MI_by_subject;

high_freqs = [65 100];

load('subjects.mat'), load('drugs.mat'), load('channels.mat')

index = 0;

for s = 1:subj_num
    
    for d = 1:no_drugs
        
        for b = 5:6
            
            index = index + 1;
            
            if index > 0 %3*4 + 1
                
                run_multivar_PAC_subject_drug(subjects{s}, peak_hours(s, d, b), drugs{d},...
                    max_phase_freq(s, d, b), [high_freqs max_amp_freq(s, d, b)], 1)
                
            end
            
        end
        
    end
    
end

end