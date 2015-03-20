function x_hat = nan_fft(x)

if size(x, 2) ~= 1
    
    if size(x, 1) == 1
        
        x = x';
        
    else
       
        display('Input x must be a column vector.')
        
    end
    
end

N = length(x);

x_hat = nan(N, 1);

t = 0:(N - 1);

for k = 0:(N - 1)
    
   basis_vec = exp(-sqrt(-1)*2*pi*k*t/N);
   
   x_hat(k + 1) = nansum(x.*basis_vec);
    
end
