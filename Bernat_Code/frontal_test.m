function [model1, model2, model3] = frontal_test

load('ALL_Frontal/ALL_Frontal_p0.99_IEzs_summed.mat')
hrs = text_read('ALL_Frontal/ALL_Frontal_p0.99_IEzs_hr_periods.txt', '%s');
hrs = [{'hrs'}; hrs(:)];
drugs = text_read('ALL_Frontal/ALL_Frontal_p0.99_IEzs_drugs.txt', '%s');
drugs = [{'drugs'}; drugs(:)];
states = text_read('ALL_Frontal/ALL_Frontal_p0.99_IEzs_states.txt', '%s');
states = [{'states'}; states(:)];
subjects = text_read('ALL_Frontal/ALL_Frontal_p0.99_IEzs_subjects.txt', '%s');
subjects = [{'subjects'}; subjects(:)];

HFObyTheta = [0; summed_MI(:,6)];
data_set = dataset(HFObyTheta, drugs, hrs, states);

tic;
model1 = GeneralizedLinearModel.stepwise(data_set, 'HFObyTheta ~ drugs*hrs*states', 'Distribution', 'Normal');
toc;

HFObyTheta_pos = max(HFObyTheta, 0);
data_set = dataset(HFObyTheta_pos, drugs, hrs, states);

tic;
model2 = GeneralizedLinearModel.stepwise(data_set, 'HFObyTheta_pos ~ drugs*hrs*states', 'Distribution', 'Poisson');
toc;

HFObyTheta_reg = HFObyTheta - min(HFObyTheta) + eps;
data_set = dataset(HFObyTheta_reg, drugs, hrs, states);

tic;
model3 = GeneralizedLinearModel.stepwise(data_set, 'HFObyTheta_reg ~ drugs*hrs*states', 'Distribution', 'Gamma');
toc;

try

save('Frontal_stat_test.mat', '-v7.3', 'model1', 'model2', 'model3')

end