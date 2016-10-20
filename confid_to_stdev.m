
function Cstd = confid_to_stdev(Cave,Cerr2,alpha)
    
    
    normcrit = norminv(1.0-alpha/2,0,1);
    
    Cstd = abs(Cerr2-Cave) / normcrit;

end