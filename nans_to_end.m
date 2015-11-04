function A_new = nans_to_end(A)

[rows, columns] = size(A);

A_new = nan(rows, columns);

for col = 1:columns
    
    A_col = A(:, col);
    
    A_col(isnan(A_col)) = [];
    
    A_new(1:length(A_col), col) = A_col;
    
end

end