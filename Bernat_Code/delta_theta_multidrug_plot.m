function delta_theta_multidrug_plot(BP_norm, ds_factor)

load('subjects.mat')

drugs = {'saline', 'NVP', 'Ro25', 'MK801'}; no_drugs = length(drugs);
   
fr = 'ALL_Frontal'; ca1 = 'ALL_CA1';

fr_BP = load([fr, '/', fr, '_BP', BP_norm, '.txt']);
fr_delta = fr_BP(:, 1);
fr_drugs = text_read([fr,'/',fr,'_drugs.txt'],'%s');
fr_subjects = text_read([fr,'/',fr,'_subjects.txt'],'%s');
fr_hrs = text_read([fr,'/',fr,'_hrs.txt'],'%s');
fr_p4_index = strcmp(fr_hrs, 'post1') | strcmp(fr_hrs, 'post2') |...
    strcmp(fr_hrs, 'post3') | strcmp(fr_hrs, 'post4');
fr_states = text_read([fr,'/',fr,'_states.txt'],'%s');

ca1_BP = load([ca1, '/', ca1, '_BP', BP_norm, '.txt']);
ca1_theta = ca1_BP(:, 2);
ca1_drugs = text_read([ca1,'/',ca1,'_drugs.txt'],'%s');
ca1_subjects = text_read([ca1,'/',ca1,'_subjects.txt'],'%s');
ca1_hrs = text_read([ca1,'/',ca1,'_hrs.txt'],'%s');
ca1_p4_index = strcmp(ca1_hrs, 'post1') | strcmp(ca1_hrs, 'post2') |...
    strcmp(ca1_hrs, 'post3') | strcmp(ca1_hrs, 'post4');
ca1_states = text_read([ca1,'/',ca1,'_states.txt'],'%s');

for d = 1:no_drugs

    drug = drugs{d};
    
    [delta, theta] = deal(nan(0));
    
    for s = 1:no_subjects
        
        if d == 1
            
            figs(s) = figure;
            
        else
            
            figure(figs(s))
            
        end
        
        subj_delta = nanzscore(fr_delta(strcmp(fr_subjects, subjects{s}) & fr_p4_index & strcmp(fr_drugs, drug)));
        
        time = (1:length(subj_delta))*16384/(1000*60*60); time = down_sample(time, ds_factor);
    
        subj_delta = down_sample(subj_delta, ds_factor);
        
        delta((end + 1):(end + length(subj_delta))) = subj_delta;
        
        subj_theta = nanzscore(ca1_theta(strcmp(ca1_subjects, subjects{s}) & ca1_p4_index & strcmp(ca1_drugs, drug)));
    
        subj_theta = down_sample(subj_theta, ds_factor);
        
        theta((end + 1):(end + length(subj_theta))) = subj_theta;
        
        subplot(no_drugs, 2, 2*d - 1)
        
        plot(time', [subj_delta subj_theta])
        
        if d == 1, legend({'Fr. \delta', 'CA1 \theta'}), end
        
        axis tight
        
        hold on
        
        plot(time', zeros(size(subj_delta)), '--k')
        
        if d == 1
            
            title(subjects{s}, 'FontSize', 16)
            
        elseif d == no_drugs
            
            xlabel('Time (h) Rel. Injection', 'FontSize', 14)
            
        end
        
        ylabel(drugs{d}, 'FontSize', 14)
        
        subplot(no_drugs, 4, (d - 1)*4 + 3)
        
        [n, c] = hist3([subj_delta subj_theta], round([50 50]/sqrt(ds_factor)));
        
        imagesc(c{1}, c{2}, n)
        
        axis xy
        
        if d == no_drugs
            
            xlabel('Fr. \delta Power')
            
        end
        
        ylabel('CA1 \theta Power')
        
        hold on
        
        nan_indicator = isnan(subj_delta) | isnan(subj_theta);
        
        subj_delta(nan_indicator) = []; subj_theta(nan_indicator) = [];
        
        p = polyfit(subj_delta, subj_theta, 1);
        
        plot(c{1}, p(1)*c{1} + p(2), 'w')
        
        [rho, p] = corr(subj_delta, subj_theta);
        
        title(['\rho = ', num2str(rho, '%.3g'), ', p = ', num2str(p, '%.3g')], 'FontSize', 16)
        
    end
    
    for s = 1:no_subjects
        
        figure(figs(s))
        
        subplot(no_drugs, 4, d*4)
        
        [n, c] = hist3([delta' theta'], round([100 100]/sqrt(ds_factor)));
        
        imagesc(c{1}, c{2}, n)
        
        axis xy
        
        if d == no_drugs
            
            xlabel('Frontal \delta Power')
            
        end
            
        ylabel('CA1 \theta Power')
        
        hold on
        
        nan_indicator = isnan(delta) | isnan(theta);
        
        delta(nan_indicator) = []; theta(nan_indicator) = [];
        
        p = polyfit(delta, theta, 1);
        
        plot(c{1}, p(1)*c{1} + p(2), 'w')
        
        [rho, p] = corr(delta', theta');
        
        title(['\rho = ', num2str(rho, '%.3g'), ', p = ', num2str(p, '%.3g')], 'FontSize', 16)
        
    end
    
end

for s = 1:no_subjects
    
    save_as_pdf(figs(s), [subjects{s}, '_theta_delta_multidrug_ds', num2str(ds_factor, '%.3g')])

end

end


function ds = down_sample(ts, ds_factor)

ts_length = length(ts);

new_length = floor(ts_length/ds_factor);

length_sampled = new_length*ds_factor;

length_left_over = ts_length - length_sampled;

start = floor(length_left_over/2);

ts_sampled = ts(start + (1:length_sampled));

ds = nanmean(reshape(ts_sampled, ds_factor, new_length))';

end
