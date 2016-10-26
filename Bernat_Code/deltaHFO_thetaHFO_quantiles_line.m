function deltaHFO_thetaHFO_quantiles_line(q)

HFO_labels = {'\delta-HFO PAC', '\theta-HFO PAC'};

hi_MI_hrs = [4 2 4 7];

load('subjects.mat'), subject_labels = subjects; clear subjects

load('channels.mat')

load('drugs.mat'), drug_labels = drugs; clear drugs

load('AP_freqs.mat')

measure = 'p0.99_IEzs';
    
median_qPAC = nan(no_afs*no_pfs, 2, no_drugs, no_channels);

overlap = nan(no_subjects, no_drugs, no_channels);

for ch = 1:no_channels
    
    channel = channel_names{ch};
    
    ch_dir = ['ALL_', channel];
    
    sMI = load([ch_dir, '/', ch_dir, '_', measure, '_summed.mat']);
    sMI = sMI.summed_MI;
    drugs = text_read([ch_dir,'/',ch_dir, '_', measure,'_drugs.txt'],'%s');
    subjects = text_read([ch_dir,'/',ch_dir, '_', measure,'_subjects.txt'],'%s');
    hrs = text_read([ch_dir,'/',ch_dir, '_', measure,'_hrs.txt'],'%s');
    MI = load([ch_dir, '/', ch_dir, '_', measure, '_hr_MI.txt']);
    
    PAC_per_subj = ceil(q*(60*60/(4.096*4)));
    
    selected_PAC = nan(no_subjects*PAC_per_subj, no_afs*no_pfs, 2, no_drugs);
    
    for s = 1:no_subjects
            
        subject = subject_labels{s};
        
        figure
        
        for d = 1:no_drugs
            
            drug = drug_labels{d};
            
            hiMI_hr_index = strcmp(hrs, sprintf('post%d', hi_MI_hrs(d)));
            
            subj_indices = strcmp(subjects, subject) & hiMI_hr_index & strcmp(drugs, drug);
                
            subj_PAC_indices = repmat(subj_indices, 1, 2);
            
            % Getting high deltaHFO & thetaHFO comodulograms.
            
            for lf = 1:2
                
                high_PAC_indices = sMI(subj_indices, end - 2 + lf) >=...
                    quantile(sMI(subj_indices, end - 2 + lf), 1 - q);
                
                subj_PAC_indices(subj_indices, lf) = high_PAC_indices;
                
                selected_PAC((s - 1)*PAC_per_subj + (1:sum(high_PAC_indices)), :, lf, d) = MI(subj_PAC_indices(:, lf), :);
            
                subplot(no_drugs, 2, (d - 1)*2 + lf)
                
                median_qPAC(:, lf, d, ch) = reshape(nanmedian(MI(subj_PAC_indices(:, lf), :)), no_afs*no_pfs, 1);
                
                imagesc(phase_freqs, amp_freqs, reshape(nanmedian(MI(subj_PAC_indices(:, lf), :)), no_afs, no_pfs))
                
                axis xy
                
                colorbar
                
                if lf == 1, ylabel({drug; 'Amp. Freq. (Hz)'}, 'FontSize', 14), end
                
                if d == 1
                    
                    if lf == 1
                        
                        title({[subject, ' ', channel]; HFO_labels{lf}}, 'FontSize', 16)
                    
                    else
                        
                        title(HFO_labels{lf}, 'FontSize', 16)
                    
                    end
                    
                elseif d == no_drugs
                    
                    xlabel('Phase Freq. (Hz)', 'FontSize', 14)
                
                end
            
            end
            
            overlap(s, d, ch) = sum(sum(subj_PAC_indices, 2) > 1)/mean(sum(subj_PAC_indices));
            
        end
        
        save_as_pdf(gcf, sprintf('%s_%s_dHFO_tHFO_quantiles_hihr_q%.3g', subject, channel, q))
        
    end
    
    figure
    
    for d = 1:no_drugs
        
        drug = drug_labels{d};
        
        for lf = 1:2
            
            subplot(no_drugs, 2, (d - 1)*2 + lf)
            
            imagesc(phase_freqs, amp_freqs, reshape(nanmedian(selected_PAC(:, :, lf, d)), no_afs, no_pfs))
            
            axis xy
            
            colorbar
            
            if lf == 1
                
                ylabel({drug; 'Amp. Freq. (Hz)'}, 'FontSize', 14)
            
            end
            
            if d == 1
                
                if lf == 1
                    
                    title({channel; HFO_labels{lf}}, 'FontSize', 16)
                
                else
                    
                    title(HFO_labels{lf}, 'FontSize', 16)
                
                end
                
            elseif d == no_drugs
                
                xlabel('Phase Freq. (Hz)', 'FontSize', 14)
                
            end
            
        end
        
    end
    
    save_as_pdf(gcf, sprintf('%s_dHFO_tHFO_quantiles_hihr_q%.3g', channel, q))
    
end

save(sprintf('dHFO_tHFO_quantiles_hihr_q%.3g.mat', q), 'median_qPAC', 'overlap')

figure

barwitherr(reshape(nanstd(overlap), no_drugs, no_channels), reshape(nanmean(overlap), no_drugs, no_channels))

set(gca, 'XTickLabel', drug_labels)

title({sprintf('Overlap of %.3g^{th} Percentiles', 100*q);'Highest \delta-HFO and \theta-HFO PAC'})

ylabel('Overlap Proportion')

legend({'Fr.', 'Occi.', 'CA1'})

save_as_pdf(gcf, sprintf('dHFO_tHFO_quantiles_hihr_q%.3g_overlap', q))