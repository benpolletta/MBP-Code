function r = ranks(X)

[rows, cols] = size(X);

r = nan(rows, cols);

for c = 1:cols
   
    [~, i] = sort(X(:, c));
    
    [~, ii] = sort(i);
    
    r(:, c) = ii;
    
end