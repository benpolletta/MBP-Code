function sad = sum_all_dimensions(Array)

Array_size = size(Array);

sad = Array;

for d = 1:(length(Array_size) - 2)
   
    sad = sum(sad);
    
    sad = reshape(sad, Array_size((d + 1):end));
    
end

sad = sum(sum(sad));