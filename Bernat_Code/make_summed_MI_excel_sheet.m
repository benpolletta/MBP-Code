function make_summed_MI_excel_sheet

load('channels'), load('drugs')

drug_names = drugs; clear drugs

measure = '_p0.99_IEzs';

for ch = 1:no_channels
    
    channel_name = ['ALL_', channel_names{ch}];
    
    drugs(:, ch) = text_read([channel_name,'/',channel_name,measure,'_drugs.txt'],'%s');
    subjects(:, ch) = text_read([channel_name,'/',channel_name,measure,'_subjects.txt'],'%s');
    hrs = text_read([channel_name,'/',channel_name,measure,'_hrs.txt'],'%s');
    p4_index(:, ch) = strcmp(hrs, 'post1') | strcmp(hrs, 'post2') |...
        strcmp(hrs, 'post3') | strcmp(hrs, 'post4');
    hours(:, ch) = hrs;
    states(:, ch) = text_read([channel_name,'/',channel_name,measure,'_states.txt'],'%s');
    load([channel_name, '/', channel_name, '_p0.99_IEzs_summed.mat'])
    sMI(:, :, ch) = summed_MI;
    
end

pairs = nchoosek(1:no_channels, 2);

for p = 1:length(pairs)
   
    display([channel_names{pairs(p, 1)}, ' and ', channel_names{pairs(p, 2)}, ':'])
    
    display(sprintf('Drugs differing = %d', sum(~strcmp(drugs(:, pairs(p, 1)), drugs(:, pairs(p, 2))))))
    
    display(sprintf('Subjects differing = %d', sum(~strcmp(states(:, pairs(p, 1)), states(:, pairs(p, 2))))))
    
    display(sprintf('Hours differing = %d', sum(~strcmp(hours(:, pairs(p, 1)), hours(:, pairs(p, 2))))))
    
    display(sprintf('States differing = %d', sum(~strcmp(states(:, pairs(p, 1)), states(:, pairs(p, 2))))))
    
end

sMI = reshape(sMI(:, (end - 1):end, :), size(sMI, 1), 2*no_channels);

fid = fopen('summed_MI_excel.txt', 'w');

fprintf(fid, make_format(4 + 2*no_channels, 's'), 'DRUG', 'SUBJECT', 'HOUR', 'STATE',...
    'FRONTAL DELTA-HFO', 'FRONTAL THETA-HFO', 'OCCIPITAL DELTA-HFO', 'OCCIPITAL THETA-HFO',...
    'CA1 DELTA-HFO', 'CA1 THETA-HFO');

format = make_format(4, 's'); format = [format(1:(end - 2)), '\t', make_format(2*no_channels, 'f')];

display(sprintf('Number of rows:\n drugs = %d\n subjects = %d\n hours = %d\n states = %d\n summed MI = %d',...
    size(drugs, 1), size(subjects, 1), size(hours, 1), size(states, 1), size(sMI, 1)))

for r = 1:length(drugs)
    
    fprintf(fid, format, drugs{r, 1}, subjects{r, 1}, hours{r, 1}, states{r, 1}, sMI(r, :));
    
end

fclose(fid);

format = format(3:end);

for d = 1:no_drugs
    
    drug_index = find(strcmp(drugs(:, 1), drug_names{d}));
    
    fid = fopen([drug_names{d}, '_summed_MI_excel.txt'], 'w');
    
    fprintf(fid, make_format(3 + 2*no_channels, 's'), 'SUBJECT', 'HOUR', 'STATE',...
        'FRONTAL DELTA-HFO', 'FRONTAL THETA-HFO', 'OCCIPITAL DELTA-HFO', 'OCCIPITAL THETA-HFO',...
        'CA1 DELTA-HFO', 'CA1 THETA-HFO');
    
    for r = 1:length(drug_index)
        
        fprintf(fid, format, subjects{drug_index(r), 1}, hours{drug_index(r), 1},...
            states{drug_index(r), 1}, sMI(drug_index(r), :));
        
    end
    
    fclose(fid);
    
end