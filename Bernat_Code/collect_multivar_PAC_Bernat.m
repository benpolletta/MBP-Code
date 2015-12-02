function collect_multivar_PAC_Bernat

load('subjects.mat'), load('drugs.mat'), load('channels.mat')

load('ALL_Frontal/ALL_Frontal_A99_summed_hrMI_6min_BP_stats.mat', 'long_band_labels')

mv_PAC_fid = fopen('multivar_PAC_PAC.txt', 'w');
subjects_fid = fopen('multivar_PAC_subjects.txt', 'w');
drugs_fid = fopen('multivar_PAC_drugs.txt', 'w');
band_fid = fopen('multivar_PAC_bands.txt', 'w');

for s = 1:subj_num
    
    for d = 1:no_drugs
        
        for b = 5:6
            
            foldername = sprintf('%s_%s_post%d_epochs/', subjects{s}, drugs{d},...
                peak_hours(s, d, b));
            
            filename = [subjects{s}, '_', drugs{d}, '_post', num2str(peak_hours(s, d, b)),...
                '_', num2str(max_phase_freq(s, d, b)), 'Hz_multivar_PAC.mat'];
            
            load([foldername, filename])
            
            mv_PAC_format = make_format(size(hour_kappa_zscored, 2), 'f');
            
            fprintf(mv_PAC_fid, mv_PAC_format, hour_kappa_zscored');
            
            for e = 1:220
                
                fprintf(subjects_fid,'%s\n', subjects{s});
                
                fprintf(drugs_fid, '%s\n', drugs{d});
                
                fprintf(band_fid, '%s\n', long_band_labels{b});
                
            end
            
        end
        
    end
    
end

end