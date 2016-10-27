function deltaHFO_thetaHFO_multidrug_plot(ds_factor, q)

load('subjects.mat'), subject_labels = subjects;

load('channels.mat')

drug_labels = {'saline', 'NVP', 'Ro25', 'MK801'}; no_drugs = length(drug_labels);

measure = 'p0.99_IEzs';

for ch = 1:no_channels
    
    channel = channel_names{ch};
    
    ch_dir = ['ALL_', channel];
    
    sMI = load([ch_dir, '/', ch_dir, '_', measure, '_summed.mat']);
    sMI = sMI.summed_MI;
    drugs = text_read([ch_dir,'/',ch_dir, '_', measure,'_drugs.txt'],'%s');
    subjects = text_read([ch_dir,'/',ch_dir, '_', measure,'_subjects.txt'],'%s');
    hrs = text_read([ch_dir,'/',ch_dir, '_', measure,'_hrs.txt'],'%s');
    p4_index = strcmp(hrs, 'post1') | strcmp(hrs, 'post2') |...
        strcmp(hrs, 'post3') | strcmp(hrs, 'post4');
    states = text_read([ch_dir,'/',ch_dir, '_', measure,'_states.txt'],'%s');
    
    for d = 1:no_drugs
        
        drug = drug_labels{d};
        
        [deltaHFO, thetaHFO] = deal(nan(0));
        
        for s = 1:no_subjects
            
            subject = subject_labels{s};
            
            if d == 1
                
                figs(s) = figure;
                
            else
                
                figure(figs(s))
                
            end
            
            subj_deltaHFO = nanzscore(sMI(strcmp(subjects, subject) & p4_index & strcmp(drugs, drug), end));
            
            subj_deltaHFO = downsample(subj_deltaHFO, ds_factor);
            
            subj_deltaHFO_high = subj_deltaHFO;
            
            subj_deltaHFO_high(subj_deltaHFO < quantile(subj_deltaHFO, 1 - q)) = nan;
            
            deltaHFO((end + 1):(end + length(subj_deltaHFO))) = subj_deltaHFO;
            
            subj_thetaHFO = nanzscore(sMI(strcmp(subjects, subject) & p4_index & strcmp(drugs, drug), end - 1));
            
            subj_thetaHFO = downsample(subj_thetaHFO, ds_factor);
            
            subj_thetaHFO_high = subj_thetaHFO;
            
            subj_thetaHFO_high(subj_thetaHFO < quantile(subj_thetaHFO, 1 - q)) = nan;
            
            thetaHFO((end + 1):(end + length(subj_thetaHFO))) = subj_thetaHFO;
            
            subplot(no_drugs, 2, 2*d - 1)
            
            hrs = 4*(1:length(subj_deltaHFO))/length(subj_deltaHFO);
            
            plot(hrs', [subj_deltaHFO subj_thetaHFO])
            
            hold on
            
            plot(hrs', [subj_deltaHFO_high subj_thetaHFO_high], '-o', 'LineWidth', 2)
            
            if d == 1, legend({[channel, ' \delta-HFO PAC'], [channel, ' \theta-HFO PAC']}), end
            
            axis tight
            
            plot(hrs', zeros(size(subj_deltaHFO)), '--k')
            
            if d == 1
                
                title([subject, ', ', channel], 'FontSize', 16)
                
            elseif d == no_drugs
                
                xlabel('Time (h) Rel. Injection', 'FontSize', 14)
                
            end
            
            ylabel(drug_labels{d}, 'FontSize', 14)
            
            subplot(no_drugs, 4, (d - 1)*4 + 3)
            
            [n, c] = hist3([subj_deltaHFO subj_thetaHFO], round([50 50]/sqrt(ds_factor)));
            
            imagesc(c{1}, c{2}, n)
            
            axis xy
            
            if d == no_drugs
                
                xlabel([channel, ' \delta-HFO PAC'])
                
            end
            
            ylabel([channel, ' \theta-HFO PAC'])
            
            hold on
            
            nan_indicator = isnan(subj_deltaHFO) | isnan(subj_thetaHFO);
            
            subj_deltaHFO(nan_indicator) = []; subj_thetaHFO(nan_indicator) = [];
            
            p_fit = polyfit(subj_deltaHFO, subj_thetaHFO, 1);
            
            plot(c{1}, p_fit(1)*c{1} + p_fit(2), 'w')
            
            [rho, p_fit] = corr(subj_deltaHFO, subj_thetaHFO);
            
            title(['\rho = ', num2str(rho, '%.3g'), ', p = ', num2str(p_fit, '%.3g')], 'FontSize', 16)
            
        end
        
        for s = 1:no_subjects
            
            figure(figs(s))
            
            subplot(no_drugs, 4, d*4)
            
            [n, c] = hist3([deltaHFO' thetaHFO'], round([100 100]/sqrt(ds_factor)));
            
            imagesc(c{1}, c{2}, n)
            
            axis xy
            
            if d == no_drugs
                
                xlabel('Frontal \delta-HFO PAC')
                
            end
            
            ylabel('CA1 \theta-HFO PAC')
            
            hold on
            
            nan_indicator = isnan(deltaHFO) | isnan(thetaHFO);
            
            deltaHFO(nan_indicator) = []; thetaHFO(nan_indicator) = [];
            
            p_fit = polyfit(deltaHFO, thetaHFO, 1);
            
            plot(c{1}, p_fit(1)*c{1} + p_fit(2), 'w')
            
            [rho, p] = corr(deltaHFO', thetaHFO');
            
            title(['\rho = ', num2str(rho, '%.3g'), ', p = ', num2str(p, '%.3g')], 'FontSize', 16)
            
            save([channel, '_', drug, '_thetaHFO_deltaHFO_multidrug_ds', num2str(ds_factor, '%.3g'), '.mat'], 'n', 'c', 'p_fit', 'rho', 'p')
            
        end
        
    end
    
    for s = 1:no_subjects
        
        save_as_pdf(figs(s), [subject_labels{s}, '_', channel, '_thetaHFO_deltaHFO_multidrug_ds', num2str(ds_factor, '%.3g')])
        
    end
    
end
