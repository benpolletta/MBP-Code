function S_out = strcmpi_two_sizes(S1, S2)

if length(S1) < length(S2)
    
    Stemp = S1;
    
    S1 = S2;
    
    S2 = Stemp;
    
end

S_out = zeros(1, length(S1));

for i = 1:length(S2)
   
    S_out = S_out | strcmpi(S2{i}, S1);
    
end