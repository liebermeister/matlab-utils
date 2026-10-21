function x = rand_given_pdf(pdf_function, x_lower, x_upper, ni,nk)

% sample random numbers from univariate distribution 
% with density given by function pdf_function
% x = rand_given_pdf(inline('1'), -1,1,100,1)
% 
% the interval is split into 10 bins, for each of them the 
% probability is geussed from the densities at its boundaries
% (trapezoidal method); then an interval is chosen at random according
% to the different probabilities; the interval is subdivided
% and the whole process is iterated 4 times.

nbin  = 10;
n_iteration = 4;

if ni*nk>1,
  for it_i = 1:ni,
    for it_k = 1:nk,
      x(it_i,it_k) = rand_given_pdf(pdf_function, x_lower, x_upper, 1,1);
    end  
  end
  return
end

x_low = x_lower;
x_del = x_upper-x_lower;
for z = 1:n_iteration,
  for it = 0:nbin,
    p(it+1) = feval(pdf_function, x_low + it/nbin * x_del);
  end
  pp = 0.5 * [p(1:end-1) + p(2:end)];
  index = sum(rand * sum(pp) >= [0, cumsum(pp(1:end-1))]);
  if index<1, 
    error('buuh'); end
  x_low = x_low + [index-1]/nbin * x_del;
  x_del = x_del / nbin;
end
x = x_low + rand * x_del;
