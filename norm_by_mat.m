function A_norm = norm_by_mat(A, B)

% Normalizes matrix A by the max/min values of matrix B, so that plots
% of both matrices overlap.

min_B = all_dimensions(@nanmin, B); max_B = all_dimensions(@nanmax, B);

min_A = all_dimensions(@nanmin, A); max_A = all_dimensions(@nanmax, A);

A_norm = (A - min_A)/(max_A - min_A);

A_norm = A_norm*(max_B - min_B) + min_B;