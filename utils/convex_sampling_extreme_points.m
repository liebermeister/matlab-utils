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
% x_start (optional, no longer used)

eval(default('x_start','[]'))

x_length = max(length(x_lower), size(M_ineq,2));

display(sprintf('%d variables, %d inequality constraints',x_length,length(b_ineq)));


z_empty = zeros(x_length,1);

X_sample = [];
X_l      = [];
X_u      = [];

for it = 1:x_length,

  zmax = z_empty; zmax(it) = -1;
  zmin = z_empty; zmin(it) =  1;

  [xmax,value,exitflag1] = lp_solve(zmax, M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper);
  [xmin,value,exitflag2] = lp_solve(zmin, M_ineq, b_ineq, M_eq, b_eq, x_lower, x_upper);

  if exitflag1 * exitflag2 < 0, 
    switch exitflag1
      case -3, error('Problem is unbounded');
      case -2, error('No feasible point found');
    end
  else
    X_sample = [X_sample, xmin, xmax];
    X_l      = [X_l, xmin];
    X_u      = [X_u, xmax];
  end
end

x_min = min(X_sample,[],2);
x_max = max(X_sample,[],2);
