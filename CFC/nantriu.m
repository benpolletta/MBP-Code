function [NT]=nantriu(M,k);

if nargin>1    
    NT=triu(M,k);
else
    NT=triu(M);
end

NT(NT==0)=nan;