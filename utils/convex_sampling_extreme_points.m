function [X_sample, x_min, x_max, X_l, X_u] = convex_sampling_extreme_points(M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper, x_start)

% [X_sample, x_min, x_max, X_l, X_u] = convex_sampling_extreme_points(M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper, x_start)
%
% This function works, but is obsolete .. you can use find_polytope_center instead
% 
% Compute vectors in a convex polytope, with extreme (minimal and maximal) values in each dimension
%
% Output
% X_sample  matrix of sampled vectors
% x_min     vector of minimal feasible values
% x_max     vector of maximal feasible values
%
% Input
% M_ineq, b_ineq
% M_eq, b_eq
% x_lower, x_upper
% x_start (optional)

eval(default('x_start','[]'))

x_length = length(x_lower);

display(sprintf('%d variables, %d inequality constraints',x_length,length(b_ineq)));


z_empty = zeros(x_length,1);

X_sample = [];

for it = 1:x_length,

  zmax = z_empty; zmax(it) = -1;
  zmin = z_empty; zmin(it) =  1;

  if exist('cplexlp','file'),
    opt =  cplexoptimset('cplex');
    %opt = cplexoptimset('Display','off');
    [xmax,value,exitflag1] = cplexlp(zmax, M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper, x_start ,opt);
    [xmin,value,exitflag2] = cplexlp(zmin, M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper, x_start ,opt);
  else  
    %opt = optimset('MaxIter',10^10,'LargeScale','off','Display','off');
    opt = optimset('Display','off');
    [xmax,value,exitflag1] = linprog(zmax, M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper, x_start ,opt);
    [xmin,value,exitflag2] = linprog(zmin, M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper, x_start ,opt);
  end

  if exitflag1 * exitflag2 < 0, 
    switch exitflag1
      case -3, error('Problem is unbounded');
      case -2, error('No feasible point found');
    end
  else
    X_sample = [X_sample, xmin, xmax];
  end
end

x_min = min(X_sample,2);
x_max = max(X_sample,2);
