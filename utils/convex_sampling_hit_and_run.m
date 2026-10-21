function [X_sample, x_min, x_max, X_l, X_u] = convex_sampling_hit_and_run(M_ineq, b_ineq, x_lower, x_upper, x_mean, x_cov, n_sample, n_warm, n_pick, flag_artificial_centering, x_start)

% [X_sample, x_min, x_max, X_l, X_u] = convex_sampling_hit_and_run(M_ineq, b_ineq, x_lower, x_upper, x_mean, x_cov, n_sample, n_warm, n_pick, flag_artificial_centering, x_start)
%
% Sampling vectors in a convex polytope
%
% Output
% X_sample  matrix of sampled vectors
% x_min     vector of minimal feasible values
% x_max     vector of maximal feasible values
% X_l       matrix of vectors hitting the lower bounds
% X_u       matrix of vectors hitting the upper bounds
%
% Input
% M_ineq
% b_ineq
% x_lower
% x_upper
% x_mean
% x_cov
% n_sample
% n_warm
% n_pick
% flag_artificial_centering
% x_start

% --------------------------------------------------------

eval(default('x_mean','[]','x_cov','[]','n_sample','[]','x_start','[]','flag_artificial_centering','0','n_warm','[]'))

if length(x_cov),
  x_cov_inv  = inv(x_cov);
  %%x_cov_sqrt = sqrtm(x_cov);
else,
  x_cov_inv = [];
  %%x_cov_sqrt = [];
end

x_length = max(size(M_ineq,2), length(x_lower));

display(sprintf('%d variables, %d inequality constraints',x_length,length(b_ineq)));

if isnan(n_warm), n_warm = []; end
if isempty(n_warm), 
  n_warm = 0.5 * n_pick * n_sample;
end

n_tot = n_warm + n_pick * n_sample;

display('Sampling polytope');

% --------------------------------------------------------

if flag_artificial_centering,
  
  %% Initial point population
  
  display(sprintf('Creating initial point population (population size %d)',2 * x_length))

  %% compute feasible ranges
  [xx,x_lo,x_up,sucess_flag,X_l,X_u] = convex_sampling(M_ineq,b_ineq,[],[],0,x_lower,x_upper);
  X_batch   = [X_l, X_u];

  %[X_batch,sucess_flag,X_l,X_u] = convex_sampling_rejection_method(M_ineq,b_ineq,2 * x_length,x_lower,x_upper);
  
  my_center = mean(X_batch,2);

  if length(x_start),
    X_batch   = 0.05 * X_batch + 0.95 * repmat(x_start,1,size(X_batch,2));
  else,
    X_batch   = 0.99 * X_batch + 0.01 * repmat(my_center,1,size(X_batch,2));
  end
  
  %% subsample if necessary

  pop_size = 5 * size(X_batch,2);
  display(sprintf('Setting population size %d',pop_size))
  if n_pick * n_sample / pop_size < 10,
    warning('DANGER!!! Sample size seems to be too small');
  end
  
  if pop_size<size(X_batch,2), 
    ind = randperm(size(X_batch,2)); ind = ind(1:pop_size); 
    X_batch = X_batch(:,ind);
  elseif pop_size>size(X_batch,2), 
    ind = ceil(size(X_batch,2)*rand(pop_size,1));
    X_batch = X_batch(:,ind);
  end

  %% Evolve population

  X_sample = [];
  for it1 = 1:ceil(n_tot/pop_size),

    fcorr = 0.01*100^-[it1/(n_tot/pop_size)];

    %% figure(3); im(X_batch-repmat(median(X_batch,2),1,size(X_batch,2))); colorbar;
    %% figure(4); clf
    %% ind_plot = 21:40;
    %% %%ind_plot = 1:size(X_batch,1);
    %% plot(min(X_l(ind_plot,:)')','r*'); hold on;
    %% plot(max(X_u(ind_plot,:)')','r*'); hold on;
    %% for it = 1:size(X_batch,2),
    %%   plot(X_batch(ind_plot,it),'.'); hold on; 
    %% end
    %% drawnow

    if mod(it1,10)==0, display(sprintf('Population sample %d/%d',it1,ceil(n_tot/pop_size))); end
    for it2 = 1:pop_size,
      my_x = X_batch(:,it2);
      %% choose other point as direction target
      ok = 0;
      while ~ok,
        it_other = ceil(pop_size*rand); 
        my_target = X_batch(:,it_other);
        if norm(my_target-my_x), ok = 1; end
      end
      my_x = get_next_point(my_x,x_length,M_ineq,b_ineq,x_lower,x_upper,x_mean,x_cov_inv,my_target,fcorr,1);
      new_X_batch(:,it2) = my_x;       
    end
    X_sample = [X_sample X_batch];
    X_batch  = new_X_batch;
    
  end

  X_sample = X_sample(:,end-[n_pick * n_sample]+1:end);
  X_sample = reshape(X_sample,size(X_sample,1)*n_pick, size(X_sample,2)/n_pick);
  X_sample = X_sample(1:x_length,:);
  
else,

  %% single point hit and run
  if isempty(x_start),
    display('Searching for polytope centre');
    x_start  = find_polytope_centre([],[],M_ineq,b_ineq,x_lower,x_upper);
    if isempty(x_start),
      error('Problem seems to be infeasible');
    end
  end

  my_x = x_start;
  
  for it = 1:n_tot,
    if mod(it,100)==0,
      display(sprintf('Sample %d/%d',it,n_tot));
    end
    my_x = get_next_point(my_x, x_length, M_ineq, b_ineq, x_lower, x_upper, x_mean, x_cov_inv,[],[],0);
    X_sample(:,it) = my_x;
  end

  if nargout>1,
    %% compute feasible ranges
    [~,~,~,~,X_l,X_u] = convex_sampling_rejection_no_eq(M_ineq,b_ineq,0,x_lower,x_upper);
  end

  X_sample = X_sample(:,end-n_pick*n_sample+1:n_pick:end);
  
end


if nargout>1,
  x_min = min(X_l')';
  x_max = max(X_u')';
end

% ----------------------------------------------------------------

function my_x_new = get_next_point(my_x,x_length,M_ineq,b_ineq,x_lower,x_upper,x_mean,x_cov_inv,my_target, fcorr,flag_artificial_centering)

%my_check(my_x, M_ineq,b_ineq,x_lower,x_upper)

cont = 0;

while ~cont,
  
  if isempty(my_target),
    z = randn(x_length,1);
  else,
    z = my_target - my_x;
  end
  % term for better mixing (PROBLEM: violates uniformity!!!)
  if length(fcorr),
    z = z + fcorr * norm(z)*randn(size(z)); 
    z = z/norm(z);
  end

  if length(x_lower),
    Ml_ineq = [-z; z];
    bl_ineq = [- x_lower + my_x; x_upper - my_x];
  else,
    Ml_ineq = [];
    bl_ineq = [];
  end
  
  epsilon = 10^-10;

  if length(b_ineq),
    Ml_ineq = [Ml_ineq;  M_ineq * z ];
    bl_ineq = [bl_ineq;  b_ineq - M_ineq * my_x - epsilon ];
  end
 
  [l1,value,exitflag1] = lp_solve( 1, Ml_ineq, bl_ineq, [], [], -inf, inf);
  [l2,value,exitflag2] = lp_solve(-1, Ml_ineq, bl_ineq, [], [], -inf, inf);
  if exitflag1 == 1 && exitflag2 == 1, 
    cont = 1;
  else 
    switch exitflag1
      case -3,
        error('Problem is unbounded');
      case -2, warning('No feasible point found');
    end
    display('Trying another sample');
  end
  
end

dim    = length(z);

if length(x_mean)==0,

  %% Sample with a power law distribution (depending on the dimensionality)  on the line
  if flag_artificial_centering,
    lambda = rand_power_law(dim-1, 1, 1, l2, l1); % 
  else,
    lambda = l1 + [l2-l1] * rand;
  end
  
  my_x_new = my_x + lambda * z; 

else,
  
  %% Sample according to gaussian distribution on the line; project
  %% x_mean and x_cov onto the line; lambda is curve parameter on line from x1 to x2
  x1 = my_x + l1 * z;
  x2 = my_x + l2 * z;
  kappa_var  = 1/((x2 - x1)' * x_cov_inv * (x2 - x1));
  kappa_mean = kappa_var * [(x_mean - x1)' * x_cov_inv * (x2 - x1)];

  %%kappa      = randn_restricted(kappa_mean, sqrt(kappa_var), 0, 1, 1);
  %%my_x_new      = x1 + kappa * [x2-x1]; 
  lambda_mean  = l1+(l2-l1)*kappa_mean;
  lambda_std   = (l2-l1) * sqrt(kappa_var);
  lambda       = rand_power_law_gaussian(dim-1,1,1,l2,l1,lambda_mean, lambda_std);
  my_x_new     = my_x + lambda * z; 

end

if my_check(my_x_new, M_ineq,b_ineq,x_lower,x_upper)
  warning('Constraints violated during sampling; sampling another point');
  my_x_new = get_next_point(my_x,x_length,M_ineq,b_ineq,x_lower,x_upper,x_mean,x_cov_inv,my_target,fcorr,flag_artificial_centering);
end

%--------------------------------------------------------------------------------

function violation = my_check(my_x, M_ineq, b_ineq, x_lower, x_upper)

if length(b_ineq),
  inequ_violated = sum([M_ineq * my_x >  b_ineq]);
else
    inequ_violated = 0;
end
if length(x_lower),
  lower_violated = sum(my_x<x_lower);
  upper_violated = sum(my_x> x_upper);
else,
  lower_violated = 0;
  upper_violated = 0;
end
  violation = inequ_violated + lower_violated + upper_violated;
if violation 
  inequ_violated
  lower_violated
  upper_violated
end
