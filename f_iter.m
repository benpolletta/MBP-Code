function out = f_iter(fcn_handle, no_iterations, in)

out = in;

for n = 1:no_iterations
   
    out = feval(fcn_handle, out);
    
end