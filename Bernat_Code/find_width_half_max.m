function find_width_half_max(drug)

load('subjects.mat')

present_dir = pwd;

for s = 1:length(subjects)
    
   record_dir = [subjects{s}, '_', drug];
   
   cd (record_dir)
   
   epoch_list = [record_dir, '_chan1_epochs.list'];
   
   epoch_names = text_read(epoch_list, '%s');
   
   epoch_no = length(epoch_names);
   
   [whm, shm_sum, max_freqs, max_vals, entropy] = deal(nan(epoch_no, 1));
   
   parfor e = 1:epoch_no
       
       data = load(epoch_names{e});
       
       [whm(e), shm_sum(e), max_freqs(e), max_vals(e), entropy(e)] = width_half_max(data, 1000, [0.25 4.75], .075, 0);
       
   end
   
   cd (present_dir)
   
   save([record_dir, '_chan1_whm.mat'], 'whm', 'shm_sum', 'max_freqs', 'max_vals', 'entropy')
   
   whm_mat = [whm shm_sum entropy]; no_criteria = size(whm_mat, 2);
   
   crit_labels = {'whm', 'shm_sum', 'entropy'};
   
   figure
   
   for c = 1:no_criteria
       
       subplot(2, no_criteria, c)
       
       [n, centers] = hist(whm_mat(:, c), 25);
       
       plot(centers, n)
       
       axis tight
       
       title(crit_labels{c})
       
       subplot(2, no_criteria, no_criteria + c)
       
       plot(whm_mat(:, c), '*')
       
       axis tight
       
   end
   
   save_as_pdf(gcf, [record_dir, '_chan1_whm'])
   
end