function make_epochs_numbers_mat_files

load('subjects'), load('drugs')

peak_hours = hour_peak_summed_MI_by_subject;

peak_hour_starts(:, :, 1) = [2200 1565 1008 1345; 1980 1345 1228 2225; 2134 1834 1734 2006;...
    1694 2274 1734 2666; 1125 1253 854 1345; 1345 1473 1294 1565];

peak_hour_starts(:, :, 2) = [1320 1345 1888 1785; 1540 1345 1008 2225; 2134 1174 2394 2006;...
    1474 1174 1954 2666; 1785 1913 634 2445; 1785 1253 1734 2225];

for b = 1:2
    
   for s = 1:subj_num
   
       subject = subjects{s};
       
       for d = 1:no_drugs
          
           drug = drugs{d};
           
           folder = sprintf('%s_%s_post%d_epochs/', subject, drug, peak_hours(s, d, b + 4));
           
           file = sprintf('%s_%s_post%d_epochs_numbers.mat', subject, drug, peak_hours(s, d, b + 4));
           
           epoch_numbers = peak_hour_starts(s, d, b):(peak_hour_starts(s, d, b) + 220 - 1);
           
           save([folder, file], 'epoch_numbers')
           
       end
       
   end
   
end