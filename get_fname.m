function function_name = get_fname(function_name)

if strcmp(class(function_name), 'function_handle')
    
    function_name = func2str(function_name);
    
end