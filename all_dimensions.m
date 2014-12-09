function ad = all_dimensions(function_handle, Array)

Array_size = size(Array);

ad = Array;

for d = 1:(length(Array_size) - 2)
   
    ad = feval(function_handle, ad);
    
    ad = reshape(ad, Array_size((d + 1):end));
    
end

ad = feval(function_handle, feval(function_handle, ad));