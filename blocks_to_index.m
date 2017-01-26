function index = blocks_to_index(blocks, time)

no_blocks = size(blocks, 1);

index = logical(zeros(size(time)));

for b = 1:no_blocks
   
    index = index | (time >= blocks(b, 1) & time <= blocks(b, 2));
    
end