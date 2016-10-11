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
   
   figure
   
   subplot(2, 2, 1)
   
   [n_whm, centers_whm] = hist(whm, 25);
   
   plot(centers_whm, n_whm)
   
   axis tight
   
   subplot(2, 2, 2)
   
   plot(whm, '*')
   
   axis tight
   
   subplot(2, 2, 3)
   
   [n_shm, centers_shm] = hist(shm_sum, 25);
   
   plot(centers_shm, n_shm)
   
   axis tight
   
   subplot(2, 2, 4)
   
   plot(shm_sum, '*')
   
   axis tight
   
   save_as_pdf(gcf, [record_dir, '_chan1_whm'])
   
end