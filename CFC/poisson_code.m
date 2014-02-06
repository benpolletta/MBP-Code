i=1;
times=0;
while times(i)<8
    tau=exprnd(.5*(1+cos(2*pi*times(i))));
    times(i+1)=times(i)+tau;
    i=i+1
end