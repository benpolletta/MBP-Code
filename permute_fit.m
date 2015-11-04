function A_prime = permute_fit(B, A)

B_dims = size(B);

A_dims = size(A);

if length(A_dims) > length(B_dims) && any(A_dims == 1)
    
    B_dims = [B_dims, ones(1, sum(A_dims == 1))];
    
end

if length(B_dims) > length(A_dims) && any(B_dims == 1)
    
    A_dims = [A_dims, ones(1, sum(B_dims == 1))];
    
end

if length(A_dims) == length(B_dims)
    
    no_dims = length(A_dims);
    
    permutation = nan(no_dims);
    
    for d = 1:no_dims
       
        permutation(:, d) = A_dims == B_dims(d);
        
    end
    
    [I, J] = find(permutation);
    
    if length(I) == no_dims
    
        A_prime = permute(A, I);
    
    elseif length(I) > no_dims
       
        display('There is more than one way to make A fit into B.')
        
        A_prime = A;
        
    elseif length(I) < no_dims
        
        display('A does not currently fit into B; try reshape_fit instead.')
        
        A_prime = A;
        
    end
    
else
   
    display('The number of dimensions of A & B must be equal to use permute_fit; try reshape_fit instead.')
    
end