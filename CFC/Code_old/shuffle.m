function [A_shuf]=shuffle(A)

[r,c]=size(A);
A_shuf=A;

times=ceil(3*log(r)/(2*log(2)))+2;

for i=1:times
    hand=rand(r,1)>.5;
    [sorted,indices]=sort(hand);
    A_shuf=A_shuf(indices,:);
end