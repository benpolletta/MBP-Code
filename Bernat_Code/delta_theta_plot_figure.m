function delta_theta_corr_figure(BP_norm, drug)

load('subjects.mat')
   
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

[delta, theta] = deal(nan(0));

figure

for s = 1:no_subjects
    
    subj_delta = nanzscore(fr_delta(strcmp(fr_subjects, subjects{s}) & fr_p4_index & strcmp(fr_drugs, drug)));
    
    delta((end + 1):(end + length(subj_delta))) = subj_delta;
    
    subj_theta = nanzscore(ca1_theta(strcmp(ca1_subjects, subjects{s}) & ca1_p4_index & strcmp(ca1_drugs, drug)));
    
    theta((end + 1):(end + length(subj_theta))) = subj_theta;
    
    subplot(3, 2, s)
    
    plot(downsample(1:length(subj_delta), 5)', [downsample(subj_delta, 5) downsample(subj_theta, 5)])
    
    axis tight
    
    title(subjects{s}, 'FontSize', 16)
    
end

save_as_pdf(gcf, [drug, '_theta_delta_line_subjects'])

% delta = fr_delta(fr_p4_index & strcmp(fr_drugs, 'NVP'));
% 
% theta = ca1_theta(ca1_p4_index & strcmp(ca1_drugs, 'NVP'));

figure

plot(downsample(1:length(delta), 5)', [downsample(delta, 5)' downsample(theta, 5)'])

axis tight

title(drug, 'FontSize', 16)

save_as_pdf(gcf, [drug, '_theta_delta_line'])
