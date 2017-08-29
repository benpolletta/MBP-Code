function blocks = index_to_blocks(index)

index_size = size(index);

if any(index_size == 1)
     
    if index_size(1) ~= 1
        
        index = index';
        
        index_size = size(index);
        
    end
    
end

index_length = index_size(1);

for column = 1:index_size(2)
    
    if any(index(:, column) == 0)
        
        d_index = diff(index(:, column));
        
        starts = find(d_index == 1) + 1;
        
        stops = find(d_index == -1);
        
    else
        
        starts = 1;
        
        stops = index_length;
        
    end
    
    if ~isempty(stops) || ~isempty(starts)
        
        if ~isempty(stops)
            
            if isempty(starts) || stops(1) < starts(1)
                
                starts = [1; starts];
                
            end
            
        end
        
        if ~isempty(starts)
            
            if isempty(stops) || starts(end) > stops(end)
                
                stops = [stops; index_length];
                
            end
            
        end
        
        stops(end) = min(stops(end), index_length);
        
        blocks{column} = [starts stops];
        
    else
        
        blocks{column} = [];
        
    end
    
end