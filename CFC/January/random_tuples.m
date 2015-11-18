function shuf_indices = random_tuples(in_noshufs, filenum, tuple_size)

if isempty(in_noshufs)
    
    shuf_indices = nan(in_noshufs, tuple_size);
    
    for n = 1:tuple_size
    
        shuf_indices(:, n) = randperm(filenum);
        
    end
    
elseif factorial(tuple_size)*nchoosek(filenum, tuple_size) < in_noshufs
    
    noshufs = factorial(tuple_size)*nchoosek(filenum, tuple_size);
    
    display(['There are not enough data files to create ', num2str(in_noshufs),...
        ' independent shuffles; there are only ', num2str(filenum),' data files, so ',...
        num2str(noshufs), ' shuffles will be created instead.'])
    
    shuf_indices = make_all_tuples(filenum, tuple_size);
    
else
    
    noshufs = in_noshufs;
    
    tuples = make_all_tuples(filenum, tuple_size); 
    
    choices = randperm(size(tuples, 1));
    
    choices = choices(1:noshufs);
    
    shuf_indices = tuples(choices, :);
    
end

end

