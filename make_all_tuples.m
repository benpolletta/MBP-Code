function tuples = make_all_tuples(filenum, tuple_size)

tuples = nan(tuple_size, nchoosek(filenum, tuple_size), factorial(tuple_size));

tuples_no_order = nchoosek(1:filenum, tuple_size);

orders = perms(1:tuple_size);

no_orders = size(orders, 1);

for o = 1:no_orders
    
    perm_matrix = zeros(tuple_size);
    
    for n = 1:tuple_size
        
        perm_matrix(n, orders(o, n)) = 1;
        
    end
    
    tuples(:, :, o) = (tuples_no_order*perm_matrix)';
    
end

tuples = fliplr(reshape(tuples, tuple_size, factorial(tuple_size)*nchoosek(filenum, tuple_size))');

end