function C = nancorr( X,Y )
% NANCORR calculates the sample correlation coefficient
%    for the series with NaNs expected.
%    X is the one series, Y is another.

[r1,c1] = size(X);
[r2,c2] = size(Y);

if r1 ~= r2
    error('The samples must be of the same length')
end

% Y(isnan(X)) = nan;
% X(isnan(Y)) = nan;
        
Xm = nanmean(X);
Ym = nanmean(Y);

X_centered = X - ones(size(X))*diag(Xm);
Y_centered = Y - ones(size(Y))*diag(Ym);

X_var = sqrt(nansum(X_centered.^2));
Y_var = sqrt(nansum(Y_centered.^2));


for i = 1:c1
    
    for j = 1:c2
        
        C0(i,j)=nansum(Y_centered(:,j).*X_centered(:,i))';
        
    end
    
end

C = diag(1./X_var)*C0*diag(1./Y_var);
        
end